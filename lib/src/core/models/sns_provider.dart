import 'package:freezed_annotation/freezed_annotation.dart';

/// SNS種別の統一enum。3 feature以上(posting/sns_accounts/history等)から参照されるため
/// core/models/ に配置する(architectureセクション参照)。
/// Firestore の `provider` フィールドと値を一致させる。
enum SnsProvider {
  @JsonValue('instagram')
  instagram,
  @JsonValue('x')
  x,
}
