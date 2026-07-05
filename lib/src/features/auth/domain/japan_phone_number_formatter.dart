/// 日本の電話番号表記とFirebase Auth `verifyPhoneNumber` が要求するE.164形式
/// (`+81...`)を相互変換するユーティリティ。
///
/// SMS認証(電話番号認証)画面(S-09)は日本国内(+81)前提の入力・表示のみを扱う
/// (要件§2「本アプリのターゲットは日本国内」・design.md 第9章「乱用対策」節
/// 「SMS Region Policyを許可リスト方式で日本(JP)のみ許可」準拠)。
abstract final class JapanPhoneNumberFormatter {
  /// 先頭が `0` の日本国内表記(例: `090-1234-5678` / `09012345678`)を
  /// E.164形式(例: `+819012345678`)へ変換する。
  ///
  /// ハイフン・空白は除去した上で判定する。先頭が `0` でない、桁数が
  /// 携帯電話番号として短すぎる等、変換できない入力は `null` を返す。
  static String? toE164(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (!digits.startsWith('0') || digits.length < 10 || digits.length > 11) {
      return null;
    }
    return '+81${digits.substring(1)}';
  }

  /// E.164形式(`+81...`)の電話番号を、下4桁以外を伏せた国内表示形式へ変換する
  /// (例: `+819012345678` → `090****5678`)。
  ///
  /// `+81` で始まらない、または表示に必要な桁数(先頭3桁+下4桁)に満たない入力は
  /// `null` を返す。
  static String? maskForDisplay(String e164) {
    if (!e164.startsWith('+81')) return null;
    final national = '0${e164.substring(3)}';
    if (national.length < 7) return null;
    final head = national.substring(0, 3);
    final tail = national.substring(national.length - 4);
    return '$head****$tail';
  }
}
