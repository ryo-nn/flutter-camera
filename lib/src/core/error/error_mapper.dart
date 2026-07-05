import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';

/// `AppException`(および想定外の例外)を日本語UIメッセージへ変換する唯一の場所。
/// (design.md アプリアーキテクチャ設計「エラーハンドリング方針」準拠。ここ以外でUI文言を組み立てない)
///
/// `toUserMessage` が `null` を返した場合、呼び出し側(`error_listener.dart` 等)は
/// SnackBar 等のエラー表示を一切行わない(例: 購入キャンセルは非エラー扱い)。
abstract final class ErrorMapper {
  static String? toUserMessage(Object error) {
    if (error is! AppException) {
      // 未分類の例外(プログラミングバグ等)。技術情報はログにのみ記録し、
      // ユーザーには「何が起きたか」+「次に取る行動」の一般文言のみ提示する。
      return '予期しないエラーが発生しました。時間をおいて再度お試しください。';
    }
    return switch (error) {
      NetworkException() => '通信に失敗しました。電波状況を確認して再試行してください。',
      AuthException() => _authMessage(error),
      SnsAuthException() => _snsAuthMessage(error),
      SnsPostException() => _snsPostMessage(error),
      RateLimitException() => _rateLimitMessage(error),
      ImageProcessingException() => '画像の加工に失敗しました。もう一度お試しください。',
      StorageException() => 'ファイルの保存に失敗しました。時間をおいて再度お試しください。',
      CameraAccessException() => _cameraAccessMessage(error),
      BillingException() => _billingMessage(error),
    };
  }

  static String _authMessage(AuthException e) {
    return switch (e.code) {
      'wrong-password' ||
      'user-not-found' ||
      'invalid-credential' =>
        'メールアドレスまたはパスワードが正しくありません。',
      'email-already-in-use' => 'このメールアドレスは登録済みです。ログインをお試しください。',
      'weak-password' => 'パスワードの強度が不足しています。6文字以上の別のパスワードを入力してください。',
      'invalid-email' => 'メールアドレスの形式が正しくありません。入力内容を確認してください。',
      'user-disabled' => 'このアカウントは無効化されています。サポートにお問い合わせください。',
      'too-many-requests' => '試行回数が上限に達しました。時間をおいて再度お試しください。',
      'network-request-failed' => '通信に失敗しました。電波状況を確認して再試行してください。',
      'credential-already-in-use' => 'この電話番号は既に別のアカウントで使用されています。',
      _ => '認証に失敗しました。入力内容を確認して再度お試しください。',
    };
  }

  static String _snsAuthMessage(SnsAuthException e) {
    if (e.requiresProAccount) {
      return 'Instagramのプロアカウントが必要です。切り替え手順をご確認ください。';
    }
    final name = _providerName(e.provider);
    return '$nameとの連携に失敗しました。時間をおいて再度お試しください。';
  }

  static String _snsPostMessage(SnsPostException e) {
    return switch (e.apiErrorCode) {
      'ig_not_professional' => 'Instagramのプロアカウントが必要です。切り替え手順をご確認ください。',
      'ig_quota_exceeded' => 'Instagramの24時間の投稿上限(100件)に達しています。時間をおいて再度お試しください。',
      'ig_container_timeout' ||
      'ig_container_error' =>
        'Instagramへの投稿処理に失敗しました。再試行してください。',
      'ig_fair_use_exceeded' => 'Instagramの本日の投稿上限に達しました。翌日以降にお試しください。',
      'x_quota_exceeded' => switch (e.quotaScope) {
          'daily' => '本日のX投稿上限に達しました。時間をおいて再度お試しください。',
          _ => '今月のX投稿上限に達しました。プランの変更またはクレジットの購入をご検討ください。',
        },
      'x_url_not_allowed' => 'キャプションにURLは含められません。URLを削除してもう一度お試しください。',
      'x_phone_verification_required' => 'Xへの投稿には電話番号認証が必要です。認証手続きへお進みください。',
      'free_quota_device_limit' => 'この端末の無料枠は別のアカウントで使用されています。',
      'token_expired' => '連携の有効期限が切れました。再連携してください。',
      'pattern_premium_required' => 'このパターンはProプラン限定です。',
      'unknown_result' => '投稿結果を確認できませんでした。投稿履歴をご確認のうえ、必要であれば再試行してください。',
      _ => '${_providerName(e.provider)}への投稿に失敗しました。時間をおいて再度お試しください。',
    };
  }

  static String _rateLimitMessage(RateLimitException e) {
    return switch (e.provider) {
      SnsProvider.instagram => 'Instagramの24時間の投稿上限(100件)に達しています。時間をおいて再度お試しください。',
      SnsProvider.x => '本日のX投稿上限に達しました。',
    };
  }

  static String _cameraAccessMessage(CameraAccessException e) {
    if (e.permissionDenied) {
      return 'カメラへのアクセスが許可されていません。撮影には許可が必要です。設定からカメラへのアクセスを許可してください。';
    }
    return 'カメラを起動できませんでした。再試行してください。';
  }

  static String? _billingMessage(BillingException e) {
    if (e.cancelled) {
      return null; // 購入キャンセルは非エラー扱い。SnackBarを出さない。
    }
    return '購入を完了できませんでした。時間をおいて再試行してください。';
  }

  static String _providerName(SnsProvider provider) {
    return switch (provider) {
      SnsProvider.instagram => 'Instagram',
      SnsProvider.x => 'X',
    };
  }
}
