import 'package:freezed_annotation/freezed_annotation.dart';

/// 課金プラン種別。posting(X投稿枠判定)・billing(ペイウォール)・
/// patterns(プレミアムパターン制御)の3 feature以上から参照されるため
/// core/models/ に昇格配置する(design.md 第9章 追補による変更点 参照)。
enum Plan {
  @JsonValue('free')
  free,
  @JsonValue('light')
  light,
  @JsonValue('pro')
  pro,
}
