import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sns_connection.freezed.dart';

/// `users/{uid}/snsConnections/{provider}` に対応するFreezedエンティティ。
///
/// (design.md アプリアーキテクチャ設計 ディレクトリ構造「sns_connection.dart
/// # Freezed(provider/接続状態/アカウント名/プロ判定)」+ backend章「参照するFirestore
/// コレクション」節 準拠)
///
/// 契約上の注記: 本モデルのフィールド名(`provider` / `status` / `username` /
/// `isProAccount` / `accountType`)は、並列実装中の posting 機能
/// (`posting/presentation/post_compose_screen.dart`)が既にこの形状に依存して
/// 実装済みである(design.md記載のパスからの推測として同ファイルに明記あり)。
/// 本featureが正のドミノとなるため、integrationフェーズで変更する場合は
/// posting機能側の参照箇所も合わせて確認すること。
@freezed
sealed class SnsConnection with _$SnsConnection {
  const SnsConnection._();

  const factory SnsConnection({
    required SnsProvider provider,
    required SnsConnectionStatus status,
    String? username,

    /// Instagramのみ意味を持つ(プロアカウント判定)。Xでは常に `null`。
    ///
    /// backend章「プロアカウント(Business/Creator)判定」節: 非プロアカウントの
    /// トークンは `igExchangeToken` が保存前に破棄するため、実装上
    /// `status == connected` のInstagramドキュメントは通常 `true` になる
    /// (`false` は将来の仕様変化・異常系に備えた防御的な値として保持する)。
    bool? isProAccount,

    /// Instagramの `account_type` 生値(例: `'BUSINESS'` / `'MEDIA_CREATOR'`。
    /// バッジ表示用。backend章「プロアカウント判定」節準拠)。
    String? accountType,
    DateTime? updatedAt,
  }) = _SnsConnection;

  bool get isConnected => status == SnsConnectionStatus.connected;

  /// Instagram連携済みだがプロアカウントではない(非プロ検出)状態。
  /// (UIフロー章 S-09「非プロ検出=赤色警告カード」節準拠)
  bool get requiresProAccountSwitch =>
      provider == SnsProvider.instagram && isConnected && isProAccount == false;
}

/// backend章「参照するFirestoreコレクション」節:
/// `SnsConnectionStatus: 'connected' | 'expired' | 'revoked' | 'error'`。
enum SnsConnectionStatus {
  @JsonValue('connected')
  connected,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('error')
  error,
}
