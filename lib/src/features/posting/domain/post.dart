import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// `posts/{postId}` ドキュメントに対応するFreezedエンティティ。
///
/// フィールド構成は実装済みCloud Functions
/// (`functions/src/sns/publishPost/postDoc.ts` / `finalize.ts` / `overallStatus.ts`)が
/// 実際に書き込むスキーマに合わせている。design.md アーキテクチャ章は
/// `Post` のフィールドを `id/userId/imageUrl/targets/各status` と記載しているが、
/// 実装済みFunctionsは画像パスを `imagePath` として書き込むため、実装を正として
/// こちらに合わせる(「基盤・既存実装と設計が食い違う場合は実装を正とする」方針。notes参照)。
///
/// Firestoreとの相互変換(`Timestamp` ⇔ `DateTime`、`DocumentSnapshot` ⇔ 本モデル)は
/// Firebase SDK型を扱うため data 層(`functions_post_repository.dart` /
/// `firestore_post_history_repository.dart`)が担当し、本ファイルはFirebase SDKに
/// 依存しない(レイヤー責務表 準拠)。
@freezed
sealed class Post with _$Post {
  const Post._();

  const factory Post({
    required String id,
    required String userId,
    required String imagePath,
    required String caption,
    String? patternId,

    /// 投稿時点のパターン名スナップショット(retention章「posts/{postId}へのフィールド追加」節。
    /// パターン削除・改名後もランキング表示を成立させるための非正規化)。
    String? patternName,
    required PostTarget instagram,
    required PostTarget x,
    required PostOverallStatus overallStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Post;

  /// [provider] に対応するターゲットを返す(S-08詳細表示等での走査用)。
  PostTarget targetFor(SnsProvider provider) => switch (provider) {
    SnsProvider.instagram => instagram,
    SnsProvider.x => x,
  };
}

/// `posts/{postId}.targets.<provider>` に対応するFreezedエンティティ。
@freezed
sealed class PostTarget with _$PostTarget {
  const PostTarget._();

  const factory PostTarget({
    required SnsProvider provider,
    required bool selected,
    required PostTargetStatus status,
    PostTargetFailureKind? failureKind,

    /// backend章「onCallエラーコード一覧」+ quota/retention章追加分の
    /// 小文字スネークケースコード(例: 'x_quota_exceeded' 等)。
    String? errorCode,
    String? errorMessage,
    String? publishedId,
    DateTime? postedAt,

    /// Xターゲットのみ設定される(quota章「Firestoreデータ設計の拡張」節準拠)。
    XQuotaSource? quotaSource,
    @Default(false) bool quotaRefunded,

    /// Instagramターゲットのみ設定される
    /// (retention章「Instagramフェアユース上限」節。`quotaIg.ts` 実装準拠)。
    @Default(false) bool fairUseRefunded,
  }) = _PostTarget;

  bool get isTerminal =>
      status == PostTargetStatus.succeeded || status == PostTargetStatus.failed;

  bool get isInProgress =>
      status == PostTargetStatus.pending ||
      status == PostTargetStatus.processing;
}
