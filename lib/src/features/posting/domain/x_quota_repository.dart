import 'package:flutter_camera/src/features/posting/domain/x_quota.dart';

/// X投稿の残枠合成(appConfig/limits・postUsage・billing/state)を担う
/// リポジトリの抽象インターフェース(design.md quota章「プロバイダー設計」節準拠)。
abstract interface class XQuotaRepository {
  /// S-07/S-09/ペイウォールの残数表示の単一情報源。
  Stream<XQuota> watchXQuota();
}
