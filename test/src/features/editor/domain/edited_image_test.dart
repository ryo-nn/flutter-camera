// NOTE(統合フェーズ申し送り): riverpod_generator/freezed のコード生成(edited_image.freezed.dart)
// は統合フェーズで一括実行する方針のため、現時点では未生成(`build_runner build` 実行後に
// 実行可能になる)。
import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('同一フィールドを持つEditedImageは等価になる(Freezedの値等価性)', () {
    const a = EditedImage(filePath: '/tmp/edited_1.jpg', isFinal: true);
    const b = EditedImage(filePath: '/tmp/edited_1.jpg', isFinal: true);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('copyWithで一部フィールドのみ更新できる', () {
    const original = EditedImage(filePath: '/tmp/preview.png', isFinal: false);

    final finalized = original.copyWith(
      filePath: '/tmp/edited_final.jpg',
      isFinal: true,
    );

    expect(finalized.filePath, '/tmp/edited_final.jpg');
    expect(finalized.isFinal, isTrue);
    // 元のインスタンスは不変。
    expect(original.filePath, '/tmp/preview.png');
    expect(original.isFinal, isFalse);
  });
}
