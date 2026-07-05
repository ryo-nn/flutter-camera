// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(monthlyStats)
final monthlyStatsProvider = MonthlyStatsProvider._();

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

final class MonthlyStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthlyStats>,
          AsyncValue<MonthlyStats>,
          AsyncValue<MonthlyStats>
        >
    with $Provider<AsyncValue<MonthlyStats>> {
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
  MonthlyStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyStatsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MonthlyStats>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MonthlyStats> create(Ref ref) {
    return monthlyStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MonthlyStats> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MonthlyStats>>(value),
    );
  }
}

String _$monthlyStatsHash() => r'efc7709eec393439fdc23edfa4a4ac93383297af';
