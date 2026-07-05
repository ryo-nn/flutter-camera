import 'package:flutter_camera/src/features/posting/domain/post.dart';

/// この投稿が「成功」と判定できるかどうか(design.md 第9章「成果ダッシュボード
/// (S-08改訂)」節の集計定義 = `MonthlyStats.fromPosts` が採用する
/// 「今月の投稿数」の判定条件と揃える: `overallStatus` が `succeeded` または
/// `partial`(partialは少なくとも1ターゲットが成功しているため「投稿が完了した」に
/// 該当する)。
bool isCountedAsSuccessfulPost(Post post) =>
    post.overallStatus == PostOverallStatus.succeeded ||
    post.overallStatus == PostOverallStatus.partial;

/// [posts](`postHistoryProvider` 由来。全期間・新しい順)のうち成功と判定できる
/// 投稿がちょうど1件だけかどうかを返す。
///
/// design.md 第9章「3日トライアル導線の接続」節: 「S-08 初回投稿完了直後」の
/// 検出条件(=このユーザーの初回投稿が今回成功した)を、「`posts` に成功
/// ドキュメントを含めて1件のみ(=初めて)である場合を検出する」との記述どおりに
/// 実装したもの。全投稿中の失敗ドキュメントは対象外のため、初回投稿が失敗した後の
/// 再投稿で初めて成功した場合も「初回投稿が今回成功した」として扱う。
bool isFirstSuccessfulPost(List<Post> posts) =>
    posts.where(isCountedAsSuccessfulPost).length == 1;
