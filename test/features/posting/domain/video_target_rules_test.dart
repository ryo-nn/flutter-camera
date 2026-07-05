import 'package:flutter_camera/src/features/posting/domain/video_target_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoTargetRules.isInstagramEligible / instagramIneligibleReason', () {
    test('3秒〜15分かつ300MB以下はチェック可', () {
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: 10,
          fileSizeBytes: 100 * 1024 * 1024,
        ),
        isTrue,
      );
      expect(
        VideoTargetRules.instagramIneligibleReason(
          durationSec: 10,
          fileSizeBytes: 100 * 1024 * 1024,
        ),
        isNull,
      );
    });

    test('3秒未満はチェック不可', () {
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: 2.9,
          fileSizeBytes: 1024,
        ),
        isFalse,
      );
      expect(
        VideoTargetRules.instagramIneligibleReason(
          durationSec: 2.9,
          fileSizeBytes: 1024,
        ),
        'Instagramは3秒〜15分以内の動画のみ投稿できます',
      );
    });

    test('15分超過はチェック不可', () {
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: 15 * 60 + 1,
          fileSizeBytes: 1024,
        ),
        isFalse,
      );
    });

    test('300MB超過はチェック不可(理由はファイルサイズを優先表示)', () {
      final oversized = 300 * 1024 * 1024 + 1;
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: 10,
          fileSizeBytes: oversized,
        ),
        isFalse,
      );
      expect(
        VideoTargetRules.instagramIneligibleReason(
          durationSec: 10,
          fileSizeBytes: oversized,
        ),
        'Instagramは300MB以内の動画のみ投稿できます',
      );
    });

    test('境界値(3秒・15分・300MB ちょうど)はチェック可', () {
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: VideoTargetRules.instagramMinDurationSec,
          fileSizeBytes: VideoTargetRules.instagramMaxFileSizeBytes,
        ),
        isTrue,
      );
      expect(
        VideoTargetRules.isInstagramEligible(
          durationSec: VideoTargetRules.instagramMaxDurationSec,
          fileSizeBytes: 0,
        ),
        isTrue,
      );
    });
  });

  group('VideoTargetRules.isXEligible / xIneligibleReason', () {
    test('0.5秒〜140秒かつ512MB以下・MP4はチェック可', () {
      expect(
        VideoTargetRules.isXEligible(
          durationSec: 30,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        isTrue,
      );
      expect(
        VideoTargetRules.xIneligibleReason(
          durationSec: 30,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        isNull,
      );
    });

    test('0.5秒未満はチェック不可', () {
      expect(
        VideoTargetRules.isXEligible(
          durationSec: 0.3,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        isFalse,
      );
      expect(
        VideoTargetRules.xIneligibleReason(
          durationSec: 0.3,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        'Xは140秒以内の動画のみ投稿できます',
      );
    });

    test('140秒超過はチェック不可(仕様書の例文と一致)', () {
      expect(
        VideoTargetRules.isXEligible(
          durationSec: 141,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        isFalse,
      );
      expect(
        VideoTargetRules.xIneligibleReason(
          durationSec: 141,
          fileSizeBytes: 1024,
          contentType: 'video/mp4',
        ),
        'Xは140秒以内の動画のみ投稿できます',
      );
    });

    test('512MB超過はチェック不可(理由はファイルサイズを優先表示)', () {
      final oversized = 512 * 1024 * 1024 + 1;
      expect(
        VideoTargetRules.isXEligible(
          durationSec: 30,
          fileSizeBytes: oversized,
          contentType: 'video/mp4',
        ),
        isFalse,
      );
      expect(
        VideoTargetRules.xIneligibleReason(
          durationSec: 30,
          fileSizeBytes: oversized,
          contentType: 'video/mp4',
        ),
        'Xは512MB以内の動画のみ投稿できます',
      );
    });

    test('境界値(0.5秒・140秒・512MB ちょうど)はチェック可', () {
      expect(
        VideoTargetRules.isXEligible(
          durationSec: VideoTargetRules.xMinDurationSec,
          fileSizeBytes: VideoTargetRules.xMaxFileSizeBytes,
          contentType: 'video/mp4',
        ),
        isTrue,
      );
      expect(
        VideoTargetRules.isXEligible(
          durationSec: VideoTargetRules.xMaxDurationSec,
          fileSizeBytes: 0,
          contentType: 'video/mp4',
        ),
        isTrue,
      );
    });

    test(
      'MOV(video/quicktime)はチェック不可(長さ・サイズが正常範囲でも選択不可。'
      'コードレビュー指摘「MOV動画のcontentType不整合」対応)',
      () {
        expect(
          VideoTargetRules.isXEligible(
            durationSec: 30,
            fileSizeBytes: 1024,
            contentType: 'video/quicktime',
          ),
          isFalse,
        );
        expect(
          VideoTargetRules.xIneligibleReason(
            durationSec: 30,
            fileSizeBytes: 1024,
            contentType: 'video/quicktime',
          ),
          'Xへの投稿はMP4形式の動画のみ対応しています',
        );
      },
    );

    test('MOVはサイズ超過も併発している場合でもcontentType理由を優先表示する', () {
      final oversized = 512 * 1024 * 1024 + 1;
      expect(
        VideoTargetRules.xIneligibleReason(
          durationSec: 30,
          fileSizeBytes: oversized,
          contentType: 'video/quicktime',
        ),
        'Xへの投稿はMP4形式の動画のみ対応しています',
      );
    });
  });
}
