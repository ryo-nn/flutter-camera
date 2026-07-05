import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Firestore Timestamp <-> DateTime 変換(design.md データモデル・ストレージ・
/// セキュリティルール設計章「converters.dart」を唯一の正としてそのまま実装する)。
///
/// auth/patterns/onboarding/billing 等、5 feature以上の Freezed モデルが
/// `@TimestampConverter()` / `@NullableTimestampConverter()` として参照するため
/// `core/models/` に配置する(既存規約「3 feature以上参照型はcore昇格」準拠)。
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

class NullableTimestampConverter
    implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
