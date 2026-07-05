import 'package:camera/camera.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_media_source.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CapturedPhoto', () {
    test('同一フィールドを持つインスタンスは等価になる(Freezed準拠)', () {
      const a = CapturedPhoto(
        imagePath: '/tmp/capture_1.jpg',
        lensDirection: CameraLensDirection.front,
      );
      const b = CapturedPhoto(
        imagePath: '/tmp/capture_1.jpg',
        lensDirection: CameraLensDirection.front,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('copyWithで一部フィールドのみ更新できる', () {
      const original = CapturedPhoto(
        imagePath: '/tmp/capture_1.jpg',
        lensDirection: CameraLensDirection.front,
      );

      final updated = original.copyWith(
        lensDirection: CameraLensDirection.back,
      );

      expect(updated.imagePath, original.imagePath);
      expect(updated.lensDirection, CameraLensDirection.back);
    });

    test('sourceの既定値はcamera(フォトライブラリ取り込み追加前の既存呼び出しと互換)', () {
      const photo = CapturedPhoto(
        imagePath: '/tmp/capture_1.jpg',
        lensDirection: CameraLensDirection.front,
      );

      expect(photo.source, CapturedMediaSource.camera);
    });

    test('フォトライブラリ由来はlensDirectionを持たない(null)', () {
      const photo = CapturedPhoto(
        imagePath: '/tmp/library_1.jpg',
        source: CapturedMediaSource.library,
      );

      expect(photo.lensDirection, isNull);
      expect(photo.source, CapturedMediaSource.library);
    });
  });
}
