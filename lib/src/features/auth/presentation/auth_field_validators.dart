import 'package:flutter_camera/src/features/auth/domain/japan_phone_number_formatter.dart';

/// S-03 ログイン/サインアップフォームの入力バリデーション。
///
/// メール形式・パスワード強度(`invalid-email` / `weak-password`)は
/// `FirebaseAuthException` 側の判定・文言(core/error/error_mapper.dart)を
/// そのまま使い、ここで二重実装しない。未入力チェックのみを行う
/// (design.md 画面設計・UIフロー章 S-03 状態表準拠)。
abstract final class AuthFieldValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください。';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください。';
    }
    return null;
  }

  /// 電話番号認証画面(S-09)の電話番号入力欄用。日本国内表記
  /// (先頭0始まり)からE.164形式へ変換できるかを検証する。
  static String? japanPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '電話番号を入力してください。';
    }
    if (JapanPhoneNumberFormatter.toE164(value) == null) {
      return '電話番号の形式が正しくありません(例: 09012345678)。';
    }
    return null;
  }

  /// 電話番号認証画面(S-09)のSMSコード入力欄用。6桁の数字のみを許可する。
  static String? smsCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '認証コードを入力してください。';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return '6桁の数字を入力してください。';
    }
    return null;
  }
}
