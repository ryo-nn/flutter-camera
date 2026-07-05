import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/editor/data/asset_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseStorage extends Mock implements FirebaseStorage {}

class _MockReference extends Mock implements Reference {}

class _MockFullMetadata extends Mock implements FullMetadata {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _FakeFile extends Fake implements File {}

void main() {
  setUpAll(() {
    // `verifyNever(() => reference.writeToFile(any()))` の `any()` が
    // 内部でダミー値を要求するため登録する(mocktailの規約)。
    // 未登録のまま`any()`がStateErrorを投げると、mocktail内部のグローバルな
    // 検証中フラグがリセットされず後続の全テストが巻き添えで失敗するため必須。
    registerFallbackValue(_FakeFile());
  });

  // design.md「カメラ・自動加工パイプライン設計」§4.3
  // 「ローカルキャッシュ(AssetCacheService)」の主要ロジックの単体テスト。
  //
  // 実際のダウンロード経路(`Reference.writeToFile` は `Future<TaskSnapshot>` を
  // 実装する `DownloadTask` を返す独自のTask型のため、mocktailでの安全なスタブ化が
  // 困難)は本テストの対象外とし、手動結合テストでの確認事項とする(notes参照)。

  late _MockFirebaseStorage storage;
  late _MockReference reference;
  late _MockFirebaseFirestore firestore;
  late _MockCollectionReference collection;
  late _MockDocumentReference document;
  late _MockDocumentSnapshot snapshot;
  late Directory tempRoot;
  late AssetCacheService service;

  const assetId = 'asset-1';
  const storagePath = 'assets/frame/frame_spring01.png';

  setUp(() async {
    storage = _MockFirebaseStorage();
    reference = _MockReference();
    when(() => storage.ref(any())).thenReturn(reference);

    firestore = _MockFirebaseFirestore();
    collection = _MockCollectionReference();
    document = _MockDocumentReference();
    snapshot = _MockDocumentSnapshot();
    when(() => firestore.collection('assets')).thenReturn(collection);
    when(() => collection.doc(assetId)).thenReturn(document);
    when(() => document.get()).thenAnswer((_) async => snapshot);
    when(() => snapshot.data()).thenReturn({'storagePath': storagePath});

    tempRoot = await Directory.systemTemp.createTemp('asset_cache_test_');
    service = AssetCacheService(
      storage: storage,
      firestore: firestore,
      cacheRootDirectory: () async => tempRoot,
    );
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  group('resolveSync', () {
    test('precache前に呼ぶとStateErrorを投げる', () {
      expect(() => service.resolveSync(assetId), throwsA(isA<StateError>()));
    });
  });

  group('ensureCached', () {
    test('世代が一致するローカルファイルが既にあれば再ダウンロードせず再利用する', () async {
      final metadata = _MockFullMetadata();
      when(() => metadata.generation).thenReturn('gen-1');
      when(() => reference.getMetadata()).thenAnswer((_) async => metadata);

      final assetDir = Directory('${tempRoot.path}/$storagePath');
      await assetDir.create(recursive: true);
      final cachedFile = File('${assetDir.path}/gen-1.png');
      await cachedFile.writeAsBytes([1, 2, 3]);

      final resolved = await service.ensureCached(assetId);

      expect(resolved, cachedFile.path);
      expect(service.resolveSync(assetId), cachedFile.path);
      // writeToFile は呼ばれない(再ダウンロードしない)。
      verifyNever(() => reference.writeToFile(any()));
    });

    test('メタデータ取得に失敗した場合は既存キャッシュへフォールバックする', () async {
      when(() => reference.getMetadata()).thenThrow(Exception('offline'));

      final assetDir = Directory('${tempRoot.path}/$storagePath');
      await assetDir.create(recursive: true);
      final fallbackFile = File('${assetDir.path}/gen-0.png');
      await fallbackFile.writeAsBytes([9, 9, 9]);

      final resolved = await service.ensureCached(assetId);

      expect(resolved, fallbackFile.path);
    });

    test('メタデータ取得失敗かつキャッシュも無い場合はStorageExceptionを投げる', () async {
      when(() => reference.getMetadata()).thenThrow(Exception('offline'));

      await expectLater(
        service.ensureCached(assetId),
        throwsA(isA<StorageException>()),
      );
    });

    test('assets/{assetId}にstoragePathが無い場合はStorageExceptionを投げる', () async {
      when(() => snapshot.data()).thenReturn(<String, dynamic>{});

      await expectLater(
        service.ensureCached(assetId),
        throwsA(isA<StorageException>()),
      );
    });

    test('同一assetIdへの同時要求はin-flightのFutureを共有する', () async {
      final metadata = _MockFullMetadata();
      when(() => metadata.generation).thenReturn('gen-1');
      var callCount = 0;
      when(() => reference.getMetadata()).thenAnswer((_) async {
        callCount++;
        return metadata;
      });

      final assetDir = Directory('${tempRoot.path}/$storagePath');
      await assetDir.create(recursive: true);
      await File('${assetDir.path}/gen-1.png').writeAsBytes([1]);

      final results = await Future.wait([
        service.ensureCached(assetId),
        service.ensureCached(assetId),
      ]);

      expect(results[0], results[1]);
      expect(callCount, 1);
    });
  });

  group('precacheAll', () {
    test('複数アセットをすべて解決する', () async {
      const otherAssetId = 'asset-2';
      const otherStoragePath = 'assets/stamp/stamp_heart01.png';
      final otherDocument = _MockDocumentReference();
      final otherSnapshot = _MockDocumentSnapshot();
      when(() => collection.doc(otherAssetId)).thenReturn(otherDocument);
      when(() => otherDocument.get()).thenAnswer((_) async => otherSnapshot);
      when(
        () => otherSnapshot.data(),
      ).thenReturn({'storagePath': otherStoragePath});

      final metadata = _MockFullMetadata();
      when(() => metadata.generation).thenReturn('gen-1');
      when(() => reference.getMetadata()).thenAnswer((_) async => metadata);

      for (final path in [storagePath, otherStoragePath]) {
        final assetDir = Directory('${tempRoot.path}/$path');
        await assetDir.create(recursive: true);
        await File('${assetDir.path}/gen-1.png').writeAsBytes([1]);
      }

      await service.precacheAll([assetId, otherAssetId, assetId]);

      expect(service.resolveSync(assetId), isNotEmpty);
      expect(service.resolveSync(otherAssetId), isNotEmpty);
    });
  });
}
