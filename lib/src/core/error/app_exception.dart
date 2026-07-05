import 'package:flutter_camera/src/core/models/sns_provider.dart';

/// 失敗の第一級表現。非同期フローでは throw して `AsyncValue.error` に載せる。
/// (design.md アプリアーキテクチャ設計「エラーハンドリング方針」準拠)
sealed class AppException implements Exception {
  const AppException(this.message); // 開発者向けメッセージ(ログ用)
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});
  final int? statusCode;
}

final class AuthException extends AppException {
  const AuthException(super.message, {required this.code}); // FirebaseAuth エラーコード
  final String code;
}

final class SnsAuthException extends AppException {
  const SnsAuthException(
    super.message, {
    required this.provider,
    this.requiresProAccount = false,
  });
  final SnsProvider provider;
  final bool requiresProAccount; // Instagram 非プロアカウント判定
}

final class SnsPostException extends AppException {
  const SnsPostException(
    super.message, {
    required this.provider,
    this.apiErrorCode,
    this.quotaScope,
  });
  final SnsProvider provider;

  /// backendセクション「onCallエラーコード一覧」の `errorCode`(小文字スネークケース。
  /// 例: 'ig_not_professional' / 'x_quota_exceeded' / 'token_expired' /
  /// 'x_phone_verification_required' / 'free_quota_device_limit' /
  /// 'ig_fair_use_exceeded' / 'pattern_premium_required' 等)。
  final String? apiErrorCode;

  /// `apiErrorCode == 'x_quota_exceeded'` 時の詳細区分('daily' | 'monthly')。
  /// quota設計の `HttpsError.details.quotaScope` に対応(design.md 第9章参照)。
  final String? quotaScope;
}

final class RateLimitException extends AppException {
  const RateLimitException(super.message, {required this.provider}); // IG 100件/24h・X 上限超過
  final SnsProvider provider;
}

final class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class CameraAccessException extends AppException {
  const CameraAccessException(super.message, {this.permissionDenied = false});
  final bool permissionDenied;
}

/// 課金(IAP)系エラー(design.md 第9章「課金(IAP)・ペイウォール設計 による変更」で追加)。
final class BillingException extends AppException {
  const BillingException(super.message, {this.cancelled = false});

  /// 購入キャンセルは非エラー扱い(SnackBar非表示。error_mapper.dart 参照)。
  final bool cancelled;
}
