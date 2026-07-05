import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/asset.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_pattern_repository.g.dart';

const _patternsCollection = 'patterns';
const _assetsCollection = 'assets';

/// `Pattern.fromJson` へのマージ変換(design.md データモデル章:
/// 「`Model.fromJson({...doc.data()!, 'id': doc.id})` のようにマージする」)。
/// Firestore SDK型を引数に取らないため単体テスト可能な純関数として切り出す。
Pattern patternFromFirestoreData(Map<String, dynamic> data, String id) =>
    Pattern.fromJson({...data, 'id': id});

Asset assetFromFirestoreData(Map<String, dynamic> data, String id) =>
    Asset.fromJson({...data, 'id': id});

/// [PatternRepository] の Firestore 実装。
///
/// トップレベル `patterns` コレクション(プリセット+マイパターンを `ownerType` で区別)、
/// および素材メタデータ `assets` コレクションを扱う
/// (design.md データモデル・ストレージ・セキュリティルール設計章 準拠。
/// クエリ・複合インデックスは実際に運用中の `firestore.indexes.json` と一致させている)。
class FirestorePatternRepository implements PatternRepository {
  FirestorePatternRepository({
    required FirebaseFirestore firestore,
    required String? ownerUid,
  }) : _firestore = firestore,
       _ownerUid = ownerUid;

  final FirebaseFirestore _firestore;

  /// 現在ログイン中ユーザーのUID(未ログイン時はnull)。
  final String? _ownerUid;

  CollectionReference<Map<String, dynamic>> get _patterns =>
      _firestore.collection(_patternsCollection);

  CollectionReference<Map<String, dynamic>> get _assets =>
      _firestore.collection(_assetsCollection);

  @override
  Stream<List<Pattern>> watchPresetPatterns() {
    return _patterns
        .where('ownerType', isEqualTo: 'preset')
        .orderBy('sortOrder')
        .snapshots()
        .map(_patternsFromSnapshot)
        .transform(_appExceptionTransformer());
  }

  @override
  Stream<List<Pattern>> watchUserPatterns() {
    final uid = _ownerUid;
    if (uid == null) return Stream.value(const <Pattern>[]);
    return _patterns
        .where('ownerUid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_patternsFromSnapshot)
        .transform(_appExceptionTransformer());
  }

  @override
  Future<Pattern> fetchPattern(String patternId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _patterns.doc(patternId).get();
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
    final data = snapshot.data();
    if (data == null) {
      throw StateError('パターンが見つかりません: $patternId');
    }
    return patternFromFirestoreData(data, snapshot.id);
  }

  @override
  Future<String> createPattern({
    required String name,
    required FilterParams filterParams,
    String? frameAssetId,
    required List<StampLayer> stampLayers,
  }) async {
    final uid = _ownerUid;
    if (uid == null) {
      throw StateError('サインインしていないためパターンを作成できません');
    }
    try {
      final docRef = _patterns.doc();
      await docRef.set({
        'ownerType': 'user',
        'ownerUid': uid,
        'name': name,
        'filterParams': filterParams.toJson(),
        'frameAssetId': frameAssetId,
        'stampLayers': stampLayers.map((s) => s.toJson()).toList(),
        'sortOrder': 0,
        // isPremium / publishedAt は Rules の hasOnly に含まれないため送信しない
        // (リテンション機能設計章準拠。クライアントからの書き込みを構造的に禁止)。
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<void> updatePattern({
    required String patternId,
    required String name,
    required FilterParams filterParams,
    String? frameAssetId,
    required List<StampLayer> stampLayers,
  }) async {
    try {
      await _patterns.doc(patternId).update({
        'name': name,
        'filterParams': filterParams.toJson(),
        'frameAssetId': frameAssetId,
        'stampLayers': stampLayers.map((s) => s.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<void> deletePattern(String patternId) async {
    try {
      await _patterns.doc(patternId).delete();
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Stream<List<Asset>> watchSelectableFrameAssets() =>
      _watchSelectableAssets('frame');

  @override
  Stream<List<Asset>> watchSelectableStampAssets() =>
      _watchSelectableAssets('stamp');

  Stream<List<Asset>> _watchSelectableAssets(String type) {
    return _assets
        .where('type', isEqualTo: type)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
          // isPremium の絞り込みはクライアント側で行う(既存複合インデックス
          // `assets(type ASC, sortOrder ASC)` の範囲に収めるため。
          // pattern_repository.dart のインターフェースコメント参照)。
          return snapshot.docs
              .map((doc) => assetFromFirestoreData(doc.data(), doc.id))
              .where((asset) => !asset.isPremium)
              .toList();
        })
        .transform(_appExceptionTransformer());
  }

  List<Pattern> _patternsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => patternFromFirestoreData(doc.data(), doc.id))
        .toList();
  }
}

AppException _toAppException(Object error) {
  if (error is FirebaseException) {
    return NetworkException(error.message ?? error.code);
  }
  return NetworkException(error.toString());
}

/// Firestore の Stream エラー(`FirebaseException` 等)を `AppException` へ変換する
/// (design.md アプリアーキテクチャ設計「エラーハンドリング方針」準拠)。
StreamTransformer<T, T> _appExceptionTransformer<T>() {
  return StreamTransformer<T, T>.fromHandlers(
    handleError: (error, stackTrace, sink) =>
        sink.addError(_toAppException(error), stackTrace),
  );
}

/// パターンリポジトリの DI(マイパターンの CRUD + 運営プリセットの取得)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「patternRepositoryProvider」)
///
/// `authStateChangesProvider` を watch し、ユーザー切替のたびに現在の uid を
/// 束縛した新しいリポジトリインスタンスへ差し替える。
@Riverpod(keepAlive: true)
PatternRepository patternRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  final ownerUid = ref.watch(authStateChangesProvider).value?.uid;
  return FirestorePatternRepository(firestore: firestore, ownerUid: ownerUid);
}

/// 運営プリセット一覧の購読(`ownerType == 'preset'`。編集・削除不可)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「presetPatternsProvider」)
@riverpod
Stream<List<Pattern>> presetPatterns(Ref ref) {
  return ref.watch(patternRepositoryProvider).watchPresetPatterns();
}

/// ログインユーザーのマイパターン一覧の購読(`ownerType == 'user'` かつ自uid)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「userPatternsProvider」)
@riverpod
Stream<List<Pattern>> userPatterns(Ref ref) {
  return ref.watch(patternRepositoryProvider).watchUserPatterns();
}

/// プリセット+マイパターンの合成一覧(撮影カルーセル・パターン管理一覧の表示用。
/// プリセット→マイパターンの順に連結し、区別は `Pattern.ownerType` で行う)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計 「patternsProvider」。
/// 設計書の型宣言は `Stream<List<Pattern>>` だが、rxdart 等の追加依存なしに
/// 2つの独立したストリームを再結合するには手動の `StreamController` 実装が必要になり
/// 複雑化するため、`ref.watch` で両ストリームの `AsyncValue` を合成する同期関数として
/// 実装した。`ref.watch(patternsProvider)` の戻り値型は両実装で
/// `AsyncValue<List<Pattern>>` と全く同一になるため、呼び出し側への影響はない
/// (coreChangeRequests/notes参照)。)
@riverpod
AsyncValue<List<Pattern>> patterns(Ref ref) {
  final presets = ref.watch(presetPatternsProvider);
  final userPatternsValue = ref.watch(userPatternsProvider);
  if (presets case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (userPatternsValue case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  final presetList = presets.value;
  final userList = userPatternsValue.value;
  if (presetList == null || userList == null) {
    return const AsyncLoading();
  }
  return AsyncData(
    combinePresetAndUserPatterns(presets: presetList, userPatterns: userList),
  );
}

/// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
/// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
/// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
/// 編集画面が自前で再取得する必要がある(notes参照)。
@riverpod
Future<Pattern> patternById(Ref ref, String patternId) {
  return ref.watch(patternRepositoryProvider).fetchPattern(patternId);
}

/// S-06a フレーム選択タブ用の選択可能な素材一覧。
@riverpod
Stream<List<Asset>> selectableFrameAssets(Ref ref) {
  return ref.watch(patternRepositoryProvider).watchSelectableFrameAssets();
}

/// S-06a スタンプ選択タブ用の選択可能な素材一覧。
@riverpod
Stream<List<Asset>> selectableStampAssets(Ref ref) {
  return ref.watch(patternRepositoryProvider).watchSelectableStampAssets();
}
