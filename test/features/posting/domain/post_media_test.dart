import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostMedia', () {
    test('PostMedia.imageは同一EditedImageで等価になる(Freezed準拠)', () {
      const a = PostMedia.image(
        EditedImage(filePath: '/tmp/edited_1.jpg', isFinal: true),
      );
      const b = PostMedia.image(
        EditedImage(filePath: '/tmp/edited_1.jpg', isFinal: true),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('PostMedia.videoは同一フィールドで等価になる', () {
      const a = PostMedia.video(
        filePath: '/tmp/video_1.mp4',
        durationSec: 12.5,
        fileSizeBytes: 2048,
        contentType: 'video/mp4',
      );
      const b = PostMedia.video(
        filePath: '/tmp/video_1.mp4',
        durationSec: 12.5,
        fileSizeBytes: 2048,
        contentType: 'video/mp4',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('switch式で image/video を判別しフィールドを取り出せる', () {
      const image = PostMedia.image(
        EditedImage(filePath: '/tmp/edited_1.jpg', isFinal: true),
      );
      const video = PostMedia.video(
        filePath: '/tmp/video_1.mp4',
        durationSec: 12.5,
        fileSizeBytes: 2048,
        contentType: 'video/mp4',
      );

      String describe(PostMedia media) => switch (media) {
        PostMediaImage(:final editedImage) => 'image:${editedImage.filePath}',
        PostMediaVideo(:final filePath, :final durationSec) =>
          'video:$filePath:$durationSec',
      };

      expect(describe(image), 'image:/tmp/edited_1.jpg');
      expect(describe(video), 'video:/tmp/video_1.mp4:12.5');
    });
  });
}
