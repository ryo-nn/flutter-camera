import 'package:flutter_camera/src/features/auth/domain/japan_phone_number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toE164', () {
    test('先頭0のハイフンなし携帯番号をE.164へ変換する', () {
      expect(JapanPhoneNumberFormatter.toE164('09012345678'), '+819012345678');
    });

    test('ハイフン・空白入りの入力を除去してから変換する', () {
      expect(
        JapanPhoneNumberFormatter.toE164('090-1234-5678'),
        '+819012345678',
      );
      expect(
        JapanPhoneNumberFormatter.toE164('090 1234 5678'),
        '+819012345678',
      );
    });

    test('10桁の固定電話番号も変換する', () {
      expect(JapanPhoneNumberFormatter.toE164('0312345678'), '+81312345678');
    });

    test('先頭が0でない場合はnullを返す', () {
      expect(JapanPhoneNumberFormatter.toE164('819012345678'), isNull);
    });

    test('桁数が短すぎる場合はnullを返す', () {
      expect(JapanPhoneNumberFormatter.toE164('0123'), isNull);
    });

    test('桁数が多すぎる場合はnullを返す', () {
      expect(JapanPhoneNumberFormatter.toE164('090123456789'), isNull);
    });

    test('空文字はnullを返す', () {
      expect(JapanPhoneNumberFormatter.toE164(''), isNull);
    });
  });

  group('maskForDisplay', () {
    test('E.164形式の携帯番号を先頭3桁+下4桁以外伏せて表示する', () {
      expect(
        JapanPhoneNumberFormatter.maskForDisplay('+819012345678'),
        '090****5678',
      );
    });

    test('+81で始まらない入力はnullを返す', () {
      expect(JapanPhoneNumberFormatter.maskForDisplay('09012345678'), isNull);
    });

    test('表示に必要な桁数に満たない入力はnullを返す', () {
      expect(JapanPhoneNumberFormatter.maskForDisplay('+8112'), isNull);
    });
  });
}
