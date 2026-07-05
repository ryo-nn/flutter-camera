import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';

/// backend章「onCallエラーコード一覧」+ quota/retention章追加分の `errorCode` を
/// `ErrorMapper` 経由で日本語文言化する(UI章「エラー文言は必ずerror_mapperで一元化」
/// 方針準拠。Firestoreの生 `errorMessage` は開発者向けログ用のため画面には出さない)。
///
/// S-07(投稿処理モーダル)・S-08(投稿履歴)の両画面で失敗理由の表示・読み上げに
/// 使う共有ロジック(旧実装は `history/presentation/post_history_screen.dart` の
/// private関数だったが、S-07側でも同じ理由文言が必要なため domain 層へ切り出した)。
String postTargetFailureReason(PostTarget target) {
  if (target.errorCode == null) {
    return '投稿に失敗しました。時間をおいて再度お試しください。';
  }
  return ErrorMapper.toUserMessage(
        SnsPostException(
          target.errorMessage ?? '',
          provider: target.provider,
          apiErrorCode: target.errorCode,
        ),
      ) ??
      '投稿に失敗しました。時間をおいて再度お試しください。';
}
