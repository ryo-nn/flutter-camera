import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pattern_asset_thumbnail_provider.g.dart';

const _assetsCollection = 'assets';

/// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
/// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
/// + 「Firebase Storage構成」準拠)
///
/// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
/// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
/// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
/// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
/// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。
@riverpod
Future<String> patternAssetDownloadUrl(Ref ref, String assetId) async {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);

  final Map<String, dynamic>? data;
  try {
    final doc = await firestore
        .collection(_assetsCollection)
        .doc(assetId)
        .get();
    data = doc.data();
  } on FirebaseException catch (e) {
    throw NetworkException(e.message ?? e.code);
  }

  final storagePath = data?['storagePath'] as String?;
  if (storagePath == null) {
    throw StateError('素材が見つかりません: $assetId');
  }

  try {
    return await storage.ref(storagePath).getDownloadURL();
  } on FirebaseException catch (e) {
    throw StorageException(e.message ?? e.code);
  }
}
