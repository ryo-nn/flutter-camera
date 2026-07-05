import 'package:flutter_camera/src/features/auth/presentation/auth_field_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFieldValidators.email', () {
    test('nullはエラーメッセージを返す', () {
      expect(AuthFieldValidators.email(null), isNotNull);
    });

    test('空文字はエラーメッセージを返す', () {
      expect(AuthFieldValidators.email(''), isNotNull);
    });

    test('空白のみもエラーメッセージを返す', () {
      expect(AuthFieldValidators.email('   '), isNotNull);
    });

    test('値がある場合はnullを返す(バリデーション通過)', () {
      expect(AuthFieldValidators.email('user@example.com'), isNull);
    });
  });

  group('AuthFieldValidators.password', () {
    test('nullはエラーメッセージを返す', () {
      expect(AuthFieldValidators.password(null), isNotNull);
    });

    test('空文字はエラーメッセージを返す', () {
      expect(AuthFieldValidators.password(''), isNotNull);
    });

    test('値がある場合はnullを返す(バリデーション通過)', () {
      expect(AuthFieldValidators.password('password123'), isNull);
    });
  });

  group('AuthFieldValidators.japanPhoneNumber', () {
    test('nullはエラーメッセージを返す', () {
      expect(AuthFieldValidators.japanPhoneNumber(null), isNotNull);
    });

    test('空文字はエラーメッセージを返す', () {
      expect(AuthFieldValidators.japanPhoneNumber(''), isNotNull);
    });

    test('E.164へ変換できない形式はエラーメッセージを返す', () {
      expect(AuthFieldValidators.japanPhoneNumber('123'), isNotNull);
      expect(AuthFieldValidators.japanPhoneNumber('9012345678'), isNotNull);
    });

    test('先頭0の携帯番号はnullを返す(バリデーション通過)', () {
      expect(AuthFieldValidators.japanPhoneNumber('09012345678'), isNull);
    });
  });

  group('AuthFieldValidators.smsCode', () {
    test('nullはエラーメッセージを返す', () {
      expect(AuthFieldValidators.smsCode(null), isNotNull);
    });

    test('空文字はエラーメッセージを返す', () {
      expect(AuthFieldValidators.smsCode(''), isNotNull);
    });

    test('6桁未満の数字はエラーメッセージを返す', () {
      expect(AuthFieldValidators.smsCode('123'), isNotNull);
    });

    test('数字以外を含む場合はエラーメッセージを返す', () {
      expect(AuthFieldValidators.smsCode('12345a'), isNotNull);
    });

    test('6桁の数字はnullを返す(バリデーション通過)', () {
      expect(AuthFieldValidators.smsCode('123456'), isNull);
    });
  });
}
