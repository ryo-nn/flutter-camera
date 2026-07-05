import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'functions_post_repository.g.dart';

/// [PostRepository] のCloud Functions/Firestore実装
/// (backend章「一括投稿の実行設計(snsPublishPost)」+「関数一覧」節準拠)。
class FunctionsPostRepository implements PostRepository {
  FunctionsPostRepository(this._functions, this._firestore);

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  @override
  String generatePostId() => _firestore.collection('posts').doc().id;

  @override
  Future<PublishPostOutcome> publishPost({
    required String postId,
    required String imagePath,
    required String caption,
    required bool instagram,
    required bool x,
    required String mediaType,
    String? patternId,
    bool force = false,
    String? deviceId,
    String? platform,
    double? durationSec,
    int? fileSizeBytes,
  }) async {
    final callable = _functions.httpsCallable(
      'snsPublishPost',
      // backend章「関数一覧」節: IGコンテナのステータスポーリングにより応答まで
      // 最大約6分かかり得るため、cloud_functionsプラグインの既定60秒タイムアウトでは
      // 必ずクライアント側でタイムアウトする。600秒を明示する(design.md必須事項)。
      options: HttpsCallableOptions(timeout: const Duration(seconds: 600)),
    );
    try {
      final response = await callable.call<Map<String, dynamic>>({
        'postId': postId,
        'imagePath': imagePath,
        'caption': caption,
        'targets': {'instagram': instagram, 'x': x},
        'mediaType': mediaType,
        'durationSec': ?durationSec,
        'fileSizeBytes': ?fileSizeBytes,
        if (force) 'force': force,
        'deviceId': ?deviceId,
        'platform': ?platform,
        'patternId': ?patternId,
      });
      final data = response.data;
      return PublishPostOutcome(
        postId: postId,
        overallStatus: _overallStatusFromWire(data['overallStatus'] as String?),
      );
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final reason = details is Map ? details['reason'] as String? : null;
      final quotaScope = details is Map
          ? details['quotaScope'] as String?
          : null;
      throw SnsPostException(
        e.message ?? '投稿処理でエラーが発生しました',
        // 単一の例外にIG/X両方の結果は載せられないため、代表として選択された
        // ターゲットの一方を示す(詳細な結果はwatchPostのFirestore購読を参照)。
        provider: x ? SnsProvider.x : SnsProvider.instagram,
        apiErrorCode: _errorCodeForReason(reason),
        quotaScope: quotaScope,
      );
    }
  }

  @override
  Stream<Post> watchPost(String postId) {
    return _firestore
        .doc('posts/$postId')
        .snapshots()
        .where((snap) => snap.exists)
        .map((snap) => _postFromFirestore(postId, snap.data()!));
  }
}

@Riverpod(keepAlive: true)
PostRepository postRepository(Ref ref) {
  return FunctionsPostRepository(
    ref.watch(firebaseFunctionsProvider),
    ref.watch(firestoreProvider),
  );
}

/// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
/// `postStatusProvider`・family(postId) 準拠)。
@riverpod
Stream<Post> postStatus(Ref ref, String postId) {
  return ref.watch(postRepositoryProvider).watchPost(postId);
}

/// backend章「onCallエラーコード一覧」+ quota/retention章追加分の
/// reason(大文字スネークケース) → errorCode(小文字スネークケース)対応。
/// `functions/src/lib/errors.ts` の `REASON_TO_ERROR_CODE` と同一対応表。
String? _errorCodeForReason(String? reason) {
  const map = <String, String?>{
    'IG_NOT_PROFESSIONAL_ACCOUNT': 'ig_not_professional',
    'IG_QUOTA_EXCEEDED': 'ig_quota_exceeded',
    'IG_CONTAINER_TIMEOUT': 'ig_container_timeout',
    'IG_CONTAINER_ERROR': 'ig_container_error',
    'X_QUOTA_EXCEEDED': 'x_quota_exceeded',
    'X_URL_NOT_ALLOWED': 'x_url_not_allowed',
    'TOKEN_EXPIRED': 'token_expired',
    'X_ALREADY_RUNNING': null,
    'POST_ALREADY_PROCESSING': null,
    'UNKNOWN_RESULT': 'unknown_result',
    'X_PHONE_VERIFICATION_REQUIRED': 'x_phone_verification_required',
    'FREE_QUOTA_DEVICE_LIMIT': 'free_quota_device_limit',
    'IG_FAIR_USE_EXCEEDED': 'ig_fair_use_exceeded',
    'PATTERN_PREMIUM_REQUIRED': 'pattern_premium_required',
    'X_MEDIA_UPLOAD_FAILED': 'x_media_upload_failed',
    'X_POST_FAILED': 'x_post_failed',
  };
  if (reason == null) return null;
  return map[reason];
}

PostOverallStatus _overallStatusFromWire(String? value) => switch (value) {
  'succeeded' => PostOverallStatus.succeeded,
  'partial' => PostOverallStatus.partial,
  'failed' => PostOverallStatus.failed,
  _ => PostOverallStatus.processing,
};

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
