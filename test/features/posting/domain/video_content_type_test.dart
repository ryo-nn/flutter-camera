import 'package:flutter_camera/src/features/posting/domain/video_content_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoContentType.fromFilePath', () {
    test('.mov拡張子はvideo/quicktimeと判定する(iPhoneフォトライブラリの標準コンテナ)', () {
      expect(
        VideoContentType.fromFilePath('/tmp/imported_video.mov'),
        'video/quicktime',
      );
    });

    test('拡張子の大文字小文字を区別しない(.MOV)', () {
      expect(
        VideoContentType.fromFilePath('/tmp/IMPORTED_VIDEO.MOV'),
        'video/quicktime',
      );
    });

    test('.mp4拡張子はvideo/mp4と判定する', () {
      expect(
        VideoContentType.fromFilePath('/tmp/recorded_video.mp4'),
        'video/mp4',
      );
    });

    test('未知の拡張子はvideo/mp4にフォールバックする', () {
      expect(
        VideoContentType.fromFilePath('/tmp/video_without_known_ext'),
        'video/mp4',
      );
    });
  });
}
