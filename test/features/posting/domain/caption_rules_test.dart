import 'package:flutter_camera/src/features/posting/domain/caption_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptionRules.xWeightedLength', () {
    test('ASCII文字は1文字=weight1として数える', () {
      expect(CaptionRules.xWeightedLength('Hello'), 5);
    });

    test('日本語(CJK)は1文字=weight2として数える', () {
      expect(CaptionRules.xWeightedLength('こんにちは'), 10);
    });

    test('URLは実際の長さに関わらずweight23として数える', () {
      const caption = 'see http://example.com/path here';
      // "see " (4) + "http://example.com/path"(23固定) + " here" (5) = 32
      expect(CaptionRules.xWeightedLength(caption), 32);
    });

    test('空文字は0', () {
      expect(CaptionRules.xWeightedLength(''), 0);
    });

    test('絵文字はweight2として数える', () {
      // U+1F600 (😀) は1コードポイントだが幅広文字としてweight2。
      expect(CaptionRules.xWeightedLength('😀'), 2);
    });
  });

  group('CaptionRules.detectUrls / containsUrl', () {
    test('スキーム付きURLを検出する', () {
      expect(CaptionRules.containsUrl('見て https://example.com/a'), isTrue);
    });

    test('スキームなしのドメイン風文字列も検出する', () {
      expect(CaptionRules.containsUrl('example.com を見てね'), isTrue);
    });

    test('URLを含まないキャプションはfalse', () {
      expect(CaptionRules.containsUrl('今日は良い天気です'), isFalse);
    });

    test('スキーム付きURLとドメイン風検出が重複する場合は1件のみ検出する', () {
      expect(CaptionRules.detectUrls('https://example.com/path').length, 1);
    });
  });

  group('CaptionRules.instagramHashtagCount / instagramMentionCount', () {
    test('ハッシュタグを数える', () {
      expect(CaptionRules.instagramHashtagCount('#one #two #three'), 3);
    });

    test('@タグを数える', () {
      expect(CaptionRules.instagramMentionCount('@user1 @user2 こんにちは'), 2);
    });

    test('ハッシュタグ・@タグが無ければ0', () {
      expect(CaptionRules.instagramHashtagCount('plain text'), 0);
      expect(CaptionRules.instagramMentionCount('plain text'), 0);
    });
  });
}
