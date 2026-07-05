import 'package:json_annotation/json_annotation.dart';

/// `posts/{postId}.targets.<provider>.status` の状態機械。
///
/// design.md アーキテクチャ章は `PostTargetStatus` を4値
/// (pending/processing/succeeded/failed)と定義しているが、
/// 実装済みの Cloud Functions(`functions/src/sns/publishPost/postDoc.ts`)は
/// 選択されなかったターゲット(`selected: false`)に `status: 'skipped'` を
/// 書き込む(design.md自身が「4値の状態機械は選択されたターゲットにのみ適用され、
/// skippedはこの状態機械の外側にある静的状態」と明記した上での実装判断)。
/// 実際に Firestore へ永続化される値に `skipped` が含まれるため、
/// クライアント側デシリアライズが失敗しないよう本 enum は5値とする
/// (「基盤は実装済み。実装と設計が食い違う場合は実装を正とする」方針に基づく。
/// notes参照)。
enum PostTargetStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('succeeded')
  succeeded,
  @JsonValue('failed')
  failed,
  @JsonValue('skipped')
  skipped,
}

/// `posts/{postId}.targets.<provider>.failureKind`
/// (backend章「冪等性(同一投稿の二重実行防止)」節 準拠)。
enum PostTargetFailureKind {
  @JsonValue('retryable')
  retryable,
  @JsonValue('permanent')
  permanent,
  @JsonValue('unknown')
  unknown,
}

/// `posts/{postId}.targets.x.quotaSource`
/// (quota章「Firestoreデータ設計の拡張」+ retention章「初回同時投稿1回保証」節 準拠)。
enum XQuotaSource {
  @JsonValue('grant')
  grant,
  @JsonValue('monthly')
  monthly,
  @JsonValue('credit')
  credit,
}

/// `posts/{postId}.overallStatus`
/// (backend章「部分失敗の扱い」節 準拠。全成功=succeeded/全失敗=failed/混在=partial/実行中=processing)。
enum PostOverallStatus {
  @JsonValue('processing')
  processing,
  @JsonValue('succeeded')
  succeeded,
  @JsonValue('partial')
  partial,
  @JsonValue('failed')
  failed,
}
