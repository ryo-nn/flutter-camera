import 'package:camera/camera.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_media_source.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CapturedVideo', () {
    test('同一フィールドを持つインスタンスは等価になる(Freezed準拠)', () {
      const a = CapturedVideo(
        videoPath: '/tmp/video_1.mp4',
        lensDirection: CameraLensDirection.front,
      );
      const b = CapturedVideo(
        videoPath: '/tmp/video_1.mp4',
        lensDirection: CameraLensDirection.front,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('sourceの既定値はcamera', () {
      const video = CapturedVideo(
        videoPath: '/tmp/video_1.mp4',
        lensDirection: CameraLensDirection.front,
      );

      expect(video.source, CapturedMediaSource.camera);
    });

    test('フォトライブラリ由来はlensDirectionを持たない(null)', () {
      const video = CapturedVideo(
        videoPath: '/tmp/library_1.mp4',
        source: CapturedMediaSource.library,
      );

      expect(video.lensDirection, isNull);
      expect(video.source, CapturedMediaSource.library);
    });

    test('copyWithで一部フィールドのみ更新できる', () {
      const original = CapturedVideo(
        videoPath: '/tmp/video_1.mp4',
        lensDirection: CameraLensDirection.front,
      );

      final updated = original.copyWith(lensDirection: CameraLensDirection.back);

      expect(updated.videoPath, original.videoPath);
      expect(updated.lensDirection, CameraLensDirection.back);
    });
  });
}
