// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_post_history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postHistoryRepository)
final postHistoryRepositoryProvider = PostHistoryRepositoryProvider._();

final class PostHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          PostHistoryRepository,
          PostHistoryRepository,
          PostHistoryRepository
        >
    with $Provider<PostHistoryRepository> {
  PostHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PostHistoryRepository create(Ref ref) {
    return postHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostHistoryRepository>(value),
    );
  }
}

String _$postHistoryRepositoryHash() =>
    r'85974c82adf435bbaf233921c54ce4917f63e9f0';

/// S-08投稿履歴一覧の購読(design.md アーキテクチャ章 `postHistoryProvider` 準拠)。
/// `monthlyStatsProvider`(history/presentation)はこのストリームを再利用して
/// 集計する(Firestoreリスナーの二重購読を避けるため。notes参照)。

@ProviderFor(postHistory)
final postHistoryProvider = PostHistoryProvider._();

/// S-08投稿履歴一覧の購読(design.md アーキテクチャ章 `postHistoryProvider` 準拠)。
/// `monthlyStatsProvider`(history/presentation)はこのストリームを再利用して
/// 集計する(Firestoreリスナーの二重購読を避けるため。notes参照)。

final class PostHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// S-08投稿履歴一覧の購読(design.md アーキテクチャ章 `postHistoryProvider` 準拠)。
  /// `monthlyStatsProvider`(history/presentation)はこのストリームを再利用して
  /// 集計する(Firestoreリスナーの二重購読を避けるため。notes参照)。
  PostHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postHistoryHash();

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    return postHistory(ref);
  }
}

String _$postHistoryHash() => r'c4dcd02e77e79f2d4d7ddc958df9d4f87736b7a5';
