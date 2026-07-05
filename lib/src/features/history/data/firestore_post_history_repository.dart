import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
// auth featureは未実装だが、既存 routing/app_router.dart が同一パスで
// authStateChangesProvider を参照しており、配置は確認済み(notes参照)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/history/domain/post_history_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_post_history_repository.g.dart';

/// [PostHistoryRepository] のFirestore実装。`posts` コレクションを
/// `userId == uid` でフィルタし `createdAt` 降順に購読する
/// (retention章「クエリとインデックス」節: 既存の複合インデックス
/// `posts(userId ASC, createdAt DESC)` で充足し、新規インデックスは不要)。
///
/// Postモデルへの変換(Timestamp⇔DateTime等)は posting機能の
/// `functions_post_repository.dart` と同等のロジックだが、feature間ルール
/// (presentation/data層の跨ぎ参照は禁止。参照してよいのはdomain層のみ)により
/// data層の変換関数を直接importできないため、本ファイル内に同等のマッピングを
/// 保持する(意図的な重複。notes参照)。
class FirestorePostHistoryRepository implements PostHistoryRepository {
  FirestorePostHistoryRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  @override
  Stream<List<Post>> watchPostHistory() {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _postFromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<bool> hasAnyPost(String uid) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}

@Riverpod(keepAlive: true)
PostHistoryRepository postHistoryRepository(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) {
    throw StateError('postHistoryRepository はログイン済みユーザーでのみ利用できます');
  }
  return FirestorePostHistoryRepository(ref.watch(firestoreProvider), uid);
}

/// S-08投稿履歴一覧の購読(design.md アーキテクチャ章 `postHistoryProvider` 準拠)。
/// `monthlyStatsProvider`(history/presentation)はこのストリームを再利用して
/// 集計する(Firestoreリスナーの二重購読を避けるため。notes参照)。
@riverpod
Stream<List<Post>> postHistory(Ref ref) {
  return ref.watch(postHistoryRepositoryProvider).watchPostHistory();
}

Post _postFromFirestore(String id, Map<String, dynamic> data) {
  final targets = data['targets'] as Map<String, dynamic>? ?? const {};
  return Post(
    id: id,
    userId: data['userId'] as String? ?? '',
    imagePath: data['imagePath'] as String? ?? '',
    caption: data['caption'] as String? ?? '',
    patternId: data['patternId'] as String?,
    patternName: data['patternName'] as String?,
    instagram: _targetFromFirestore(
      SnsProvider.instagram,
      targets['instagram'] as Map<String, dynamic>? ?? const {},
    ),
    x: _targetFromFirestore(
      SnsProvider.x,
      targets['x'] as Map<String, dynamic>? ?? const {},
    ),
    overallStatus: _overallStatusFromWire(data['overallStatus'] as String?),
    createdAt: _timestampToDate(data['createdAt']) ?? DateTime.now(),
    updatedAt: _timestampToDate(data['updatedAt']) ?? DateTime.now(),
  );
}

PostTarget _targetFromFirestore(
  SnsProvider provider,
  Map<String, dynamic> data,
) {
  return PostTarget(
    provider: provider,
    selected: data['selected'] as bool? ?? false,
    status: _statusFromWire(data['status'] as String?),
    failureKind: _failureKindFromWire(data['failureKind'] as String?),
    errorCode: data['errorCode'] as String?,
    errorMessage: data['errorMessage'] as String?,
    publishedId: data['publishedId'] as String?,
    postedAt: _timestampToDate(data['postedAt']),
    quotaSource: _quotaSourceFromWire(data['quotaSource'] as String?),
    quotaRefunded: data['quotaRefunded'] as bool? ?? false,
    fairUseRefunded: data['fairUseRefunded'] as bool? ?? false,
  );
}

PostOverallStatus _overallStatusFromWire(String? value) => switch (value) {
  'succeeded' => PostOverallStatus.succeeded,
  'partial' => PostOverallStatus.partial,
  'failed' => PostOverallStatus.failed,
  _ => PostOverallStatus.processing,
};

PostTargetStatus _statusFromWire(String? value) => switch (value) {
  'pending' => PostTargetStatus.pending,
  'processing' => PostTargetStatus.processing,
  'succeeded' => PostTargetStatus.succeeded,
  'failed' => PostTargetStatus.failed,
  _ => PostTargetStatus.skipped,
};

PostTargetFailureKind? _failureKindFromWire(String? value) => switch (value) {
  'retryable' => PostTargetFailureKind.retryable,
  'permanent' => PostTargetFailureKind.permanent,
  'unknown' => PostTargetFailureKind.unknown,
  _ => null,
};

XQuotaSource? _quotaSourceFromWire(String? value) => switch (value) {
  'grant' => XQuotaSource.grant,
  'monthly' => XQuotaSource.monthly,
  'credit' => XQuotaSource.credit,
  _ => null,
};

DateTime? _timestampToDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  return null;
}
