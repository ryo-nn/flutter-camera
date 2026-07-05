import 'package:flutter_camera/src/features/history/data/firestore_post_history_repository.dart';
import 'package:flutter_camera/src/features/history/domain/monthly_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monthly_stats_provider.g.dart';

const _jstOffset = Duration(hours: 9);

/// 当月開始時刻(JST 0:00)をUTC基準のDateTimeとして返す
/// (retention章「クエリとインデックス」節: 「月初境界はデバイスのタイムゾーンに
/// 依存せずJST固定で計算する」との記載準拠。postUsageのperiodKey算出と同じ
/// +9時間固定オフセット方式=日本はDSTを採用しないため)。
DateTime _monthStartJst(DateTime now) {
  final jst = now.toUtc().add(_jstOffset);
  final jstMonthStart = DateTime.utc(jst.year, jst.month, 1);
  return jstMonthStart.subtract(_jstOffset);
}

/// 当月のposts購読+メモリ内集計(S-08ダッシュボード。design.md アーキテクチャ章
/// `monthlyStatsProvider` 準拠)。`postHistoryProvider` の既存購読を再利用し、
/// 追加のFirestoreリスナーを開かない(`fromPosts` がpostごとの日付でフィルタするため、
/// 履歴全件ストリームをそのまま渡してよい)。
///
/// riverpod 3.2.1(pubspec.yaml NOTE参照)には `StreamProvider.stream` 相当の
/// モディファイアが存在しない(`.future` のみ)ため、`postHistoryProvider` の
/// `AsyncValue<List<Post>>` を `whenData` で変換する形にする(patterns/data/
/// firestore_pattern_repository.dart の `patternsProvider` と同一パターン)。
/// `ref.watch(monthlyStatsProvider)` が返す `AsyncValue<MonthlyStats>` の形は
/// Stream版と変わらないため呼び出し側(post_history_screen.dart)への影響はない。
@riverpod
AsyncValue<MonthlyStats> monthlyStats(Ref ref) {
  final monthStartJst = _monthStartJst(DateTime.now());
  return ref
      .watch(postHistoryProvider)
      .whenData(
        (posts) => MonthlyStats.fromPosts(posts, monthStartJst: monthStartJst),
      );
}
