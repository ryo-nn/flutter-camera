import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';

/// SNS連携状態の取得・トークン交換Functions呼び出し・連携解除を担う
/// リポジトリの抽象インターフェース。
///
/// (design.md アプリアーキテクチャ設計「レイヤー責務と依存方向」準拠。
/// presentationはこの型のみに依存し、data層の実装クラスを直接importしない)
abstract interface class SnsAccountRepository {
  /// Instagram / X の連携状態購読(`snsConnectionsProvider` の購読対象。
  /// design.md アーキテクチャ章「プロバイダー設計」準拠)。
  ///
  /// 一度も連携したことがないプロバイダーは戻り値のリストに含まれない
  /// (backend章: `users/{uid}/snsConnections/{provider}` ドキュメントが
  /// 存在しない = 未連携、として扱う)。
  Stream<List<SnsConnection>> watchConnections();

  /// Instagram認可コードを Cloud Functions(`igExchangeToken`)へ渡し、
  /// 短期→長期トークン交換・プロアカウント判定・保存を行わせる。
  ///
  /// 非プロアカウント判定時は保存されず、
  /// [SnsAuthException](`requiresProAccount: true`) が throw される
  /// (backend章「プロアカウント(Business/Creator)判定」節準拠)。
  Future<void> exchangeInstagramCode({
    required String code,
    required String redirectUri,
  });

  /// X認可コード + PKCE検証子を Cloud Functions(`xExchangeToken`)へ渡す
  /// (backend章「X連携設計」節準拠)。
  Future<void> exchangeXCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  });

  /// 連携解除(`snsDisconnect` onCall。backend章「リフレッシュトークン運用」節準拠)。
  Future<void> disconnect(SnsProvider provider);
}
