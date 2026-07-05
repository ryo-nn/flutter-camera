import 'package:flutter_camera/src/features/camera/domain/video_recording_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoRecordingLimits', () {
    final startedAt = DateTime(2026, 1, 1, 12, 0, 0);

    test('elapsedSecondsは経過秒数を切り捨てで返す', () {
      final now = startedAt.add(const Duration(seconds: 42, milliseconds: 900));

      expect(VideoRecordingLimits.elapsedSeconds(startedAt, now), 42);
    });

    test('elapsedSecondsは経過時間が負(想定外)の場合0を返す', () {
      final now = startedAt.subtract(const Duration(seconds: 1));

      expect(VideoRecordingLimits.elapsedSeconds(startedAt, now), 0);
    });

    test('shouldAutoStopは140秒未満はfalse', () {
      final now = startedAt.add(const Duration(seconds: 139));

      expect(VideoRecordingLimits.shouldAutoStop(startedAt, now), isFalse);
    });

    test('shouldAutoStopはちょうど140秒でtrue', () {
      final now = startedAt.add(VideoRecordingLimits.maxDuration);

      expect(VideoRecordingLimits.shouldAutoStop(startedAt, now), isTrue);
    });

    test('shouldAutoStopは140秒超過でtrue', () {
      final now = startedAt.add(const Duration(seconds: 200));

      expect(VideoRecordingLimits.shouldAutoStop(startedAt, now), isTrue);
    });
  });
}
