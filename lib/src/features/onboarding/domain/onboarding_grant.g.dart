// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_grant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingGrant _$OnboardingGrantFromJson(Map<String, dynamic> json) =>
    _OnboardingGrant(
      uid: json['uid'] as String,
      firstPostUsedAt: const TimestampConverter().fromJson(
        json['firstPostUsedAt'] as Timestamp,
      ),
      firstPostId: json['firstPostId'] as String,
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$OnboardingGrantToJson(_OnboardingGrant instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'firstPostUsedAt': const TimestampConverter().toJson(
        instance.firstPostUsedAt,
      ),
      'firstPostId': instance.firstPostId,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
