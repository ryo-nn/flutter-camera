import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/models/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_grant.freezed.dart';
part 'onboarding_grant.g.dart';

/// `onboardingGrants/{uid}` の読み取り専用ドメインモデル
/// (design.md 第9章「初回同時投稿1回保証(無料枠と別管理)」参照)。
///
/// ドキュメント不存在 = 保証未消費(`onboardingGrantProvider` が `null` を返す。
/// 既存 `postUsage` と同じ「not-found を正常系として読む」パターン)。
/// 消費(`tx.create`)・返還(削除)は `snsPublishPost`(Cloud Functions・Admin SDK)
/// のみが行うため、クライアント(本モデル)は読み取り専用のミラーとして扱う。
///
/// `@TimestampConverter()` は `auth/domain/app_user.dart` と同じ
/// `core/models/converters.dart` を参照する(コードベース共通のFirestore
/// Timestamp⇔DateTime変換規約。coreChangeRequests参照)。
@freezed
sealed class OnboardingGrant with _$OnboardingGrant {
  const factory OnboardingGrant({
    required String uid,
    @TimestampConverter() required DateTime firstPostUsedAt,
    required String firstPostId,
    @TimestampConverter() required DateTime updatedAt,
  }) = _OnboardingGrant;

  factory OnboardingGrant.fromJson(Map<String, Object?> json) =>
      _$OnboardingGrantFromJson(json);
}
