import 'package:freezed_annotation/freezed_annotation.dart';

part 'edited_image.freezed.dart';

/// 画面5(加工プレビュー)の加工確定結果(design.md アプリアーキテクチャ設計
/// ディレクトリ構造 `editor/domain/edited_image.dart` 準拠)。
///
/// [isFinal] が `true` のときのみ、[filePath] は§5仕様(JPEG・8MB以内・4:5〜1.91:1)
/// を満たす最終出力であり、SNS投稿画面(S-07)へ `extra` として渡してよい。
/// `false` の間は正規化直後 or 軽量プレビュー適用中の一時ファイルを指し、
/// 投稿フローには渡さない(GoRouter側の `redirect` で `EditedImage` 型チェックのみ行うため、
/// 呼び出し側は必ず `isFinal == true` を確認してから遷移する)。
@freezed
abstract class EditedImage with _$EditedImage {
  const factory EditedImage({required String filePath, required bool isFinal}) =
      _EditedImage;
}
