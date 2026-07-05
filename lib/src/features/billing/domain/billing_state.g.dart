// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingState _$BillingStateFromJson(Map<String, dynamic> json) =>
    _BillingState(
      plan: $enumDecodeNullable(_$PlanEnumMap, json['plan']) ?? Plan.free,
      isTrial: json['isTrial'] as bool? ?? false,
      planProductId: json['planProductId'] as String?,
      planExpiresAt: const NullableTimestampConverter().fromJson(
        json['planExpiresAt'] as Timestamp?,
      ),
      postCredits: (json['postCredits'] as num?)?.toInt() ?? 0,
      updatedAt: const NullableTimestampConverter().fromJson(
        json['updatedAt'] as Timestamp?,
      ),
    );

Map<String, dynamic> _$BillingStateToJson(
  _BillingState instance,
) => <String, dynamic>{
  'plan': _$PlanEnumMap[instance.plan]!,
  'isTrial': instance.isTrial,
  'planProductId': instance.planProductId,
  'planExpiresAt': const NullableTimestampConverter().toJson(
    instance.planExpiresAt,
  ),
  'postCredits': instance.postCredits,
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$PlanEnumMap = {Plan.free: 'free', Plan.light: 'light', Plan.pro: 'pro'};
