// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_pattern_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// パターンリポジトリの DI(マイパターンの CRUD + 運営プリセットの取得)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「patternRepositoryProvider」)
///
/// `authStateChangesProvider` を watch し、ユーザー切替のたびに現在の uid を
/// 束縛した新しいリポジトリインスタンスへ差し替える。

@ProviderFor(patternRepository)
final patternRepositoryProvider = PatternRepositoryProvider._();

/// パターンリポジトリの DI(マイパターンの CRUD + 運営プリセットの取得)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「patternRepositoryProvider」)
///
/// `authStateChangesProvider` を watch し、ユーザー切替のたびに現在の uid を
/// 束縛した新しいリポジトリインスタンスへ差し替える。

final class PatternRepositoryProvider
    extends
        $FunctionalProvider<
          PatternRepository,
          PatternRepository,
          PatternRepository
        >
    with $Provider<PatternRepository> {
  /// パターンリポジトリの DI(マイパターンの CRUD + 運営プリセットの取得)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
  /// 「patternRepositoryProvider」)
  ///
  /// `authStateChangesProvider` を watch し、ユーザー切替のたびに現在の uid を
  /// 束縛した新しいリポジトリインスタンスへ差し替える。
  PatternRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patternRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patternRepositoryHash();

  @$internal
  @override
  $ProviderElement<PatternRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PatternRepository create(Ref ref) {
    return patternRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PatternRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PatternRepository>(value),
    );
  }
}

String _$patternRepositoryHash() => r'5452c5d2659398150db94acc1f41438ebcebb9f7';

/// 運営プリセット一覧の購読(`ownerType == 'preset'`。編集・削除不可)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「presetPatternsProvider」)

@ProviderFor(presetPatterns)
final presetPatternsProvider = PresetPatternsProvider._();

/// 運営プリセット一覧の購読(`ownerType == 'preset'`。編集・削除不可)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「presetPatternsProvider」)

final class PresetPatternsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pattern>>,
          List<Pattern>,
          Stream<List<Pattern>>
        >
    with $FutureModifier<List<Pattern>>, $StreamProvider<List<Pattern>> {
  /// 運営プリセット一覧の購読(`ownerType == 'preset'`。編集・削除不可)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
  /// 「presetPatternsProvider」)
  PresetPatternsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presetPatternsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presetPatternsHash();

  @$internal
  @override
  $StreamProviderElement<List<Pattern>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Pattern>> create(Ref ref) {
    return presetPatterns(ref);
  }
}

String _$presetPatternsHash() => r'8e3522fe28b7e4337e2eb5755c13ef3eb57b4e46';

/// ログインユーザーのマイパターン一覧の購読(`ownerType == 'user'` かつ自uid)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「userPatternsProvider」)

@ProviderFor(userPatterns)
final userPatternsProvider = UserPatternsProvider._();

/// ログインユーザーのマイパターン一覧の購読(`ownerType == 'user'` かつ自uid)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「userPatternsProvider」)

final class UserPatternsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pattern>>,
          List<Pattern>,
          Stream<List<Pattern>>
        >
    with $FutureModifier<List<Pattern>>, $StreamProvider<List<Pattern>> {
  /// ログインユーザーのマイパターン一覧の購読(`ownerType == 'user'` かつ自uid)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
  /// 「userPatternsProvider」)
  UserPatternsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPatternsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPatternsHash();

  @$internal
  @override
  $StreamProviderElement<List<Pattern>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Pattern>> create(Ref ref) {
    return userPatterns(ref);
  }
}

String _$userPatternsHash() => r'0e72926e466b7f4d448e02c1ff554ab1118696bd';

/// プリセット+マイパターンの合成一覧(撮影カルーセル・パターン管理一覧の表示用。
/// プリセット→マイパターンの順に連結し、区別は `Pattern.ownerType` で行う)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計 「patternsProvider」。
/// 設計書の型宣言は `Stream<List<Pattern>>` だが、rxdart 等の追加依存なしに
/// 2つの独立したストリームを再結合するには手動の `StreamController` 実装が必要になり
/// 複雑化するため、`ref.watch` で両ストリームの `AsyncValue` を合成する同期関数として
/// 実装した。`ref.watch(patternsProvider)` の戻り値型は両実装で
/// `AsyncValue<List<Pattern>>` と全く同一になるため、呼び出し側への影響はない
/// (coreChangeRequests/notes参照)。)

@ProviderFor(patterns)
final patternsProvider = PatternsProvider._();

/// プリセット+マイパターンの合成一覧(撮影カルーセル・パターン管理一覧の表示用。
/// プリセット→マイパターンの順に連結し、区別は `Pattern.ownerType` で行う)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計 「patternsProvider」。
/// 設計書の型宣言は `Stream<List<Pattern>>` だが、rxdart 等の追加依存なしに
/// 2つの独立したストリームを再結合するには手動の `StreamController` 実装が必要になり
/// 複雑化するため、`ref.watch` で両ストリームの `AsyncValue` を合成する同期関数として
/// 実装した。`ref.watch(patternsProvider)` の戻り値型は両実装で
/// `AsyncValue<List<Pattern>>` と全く同一になるため、呼び出し側への影響はない
/// (coreChangeRequests/notes参照)。)

final class PatternsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pattern>>,
          AsyncValue<List<Pattern>>,
          AsyncValue<List<Pattern>>
        >
    with $Provider<AsyncValue<List<Pattern>>> {
  /// プリセット+マイパターンの合成一覧(撮影カルーセル・パターン管理一覧の表示用。
  /// プリセット→マイパターンの順に連結し、区別は `Pattern.ownerType` で行う)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計 「patternsProvider」。
  /// 設計書の型宣言は `Stream<List<Pattern>>` だが、rxdart 等の追加依存なしに
  /// 2つの独立したストリームを再結合するには手動の `StreamController` 実装が必要になり
  /// 複雑化するため、`ref.watch` で両ストリームの `AsyncValue` を合成する同期関数として
  /// 実装した。`ref.watch(patternsProvider)` の戻り値型は両実装で
  /// `AsyncValue<List<Pattern>>` と全く同一になるため、呼び出し側への影響はない
  /// (coreChangeRequests/notes参照)。)
  PatternsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patternsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patternsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Pattern>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Pattern>> create(Ref ref) {
    return patterns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Pattern>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Pattern>>>(value),
    );
  }
}

String _$patternsHash() => r'97b33e16b861f8609397ddb70597fb5161187e21';

/// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
/// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
/// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
/// 編集画面が自前で再取得する必要がある(notes参照)。

@ProviderFor(patternById)
final patternByIdProvider = PatternByIdFamily._();

/// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
/// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
/// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
/// 編集画面が自前で再取得する必要がある(notes参照)。

final class PatternByIdProvider
    extends $FunctionalProvider<AsyncValue<Pattern>, Pattern, FutureOr<Pattern>>
    with $FutureModifier<Pattern>, $FutureProvider<Pattern> {
  /// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
  /// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
  /// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
  /// 編集画面が自前で再取得する必要がある(notes参照)。
  PatternByIdProvider._({
    required PatternByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patternByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patternByIdHash();

  @override
  String toString() {
    return r'patternByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Pattern> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Pattern> create(Ref ref) {
    final argument = this.argument as String;
    return patternById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PatternByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patternByIdHash() => r'd4c40ca1f1d68b9bcd9cd95d6787c8e0891b9aa4';

/// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
/// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
/// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
/// 編集画面が自前で再取得する必要がある(notes参照)。

final class PatternByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Pattern>, String> {
  PatternByIdFamily._()
    : super(
        retry: null,
        name: r'patternByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// S-06a 編集画面の初期値ロード用(既存パターンをIDで取得)。
  /// design.md のプロバイダー表に明記が無いが、`/patterns/:patternId` ルートは
  /// パターン本体を `extra` で渡さない(実装済み `app_router.dart` 準拠)ため、
  /// 編集画面が自前で再取得する必要がある(notes参照)。

  PatternByIdProvider call(String patternId) =>
      PatternByIdProvider._(argument: patternId, from: this);

  @override
  String toString() => r'patternByIdProvider';
}

/// S-06a フレーム選択タブ用の選択可能な素材一覧。

@ProviderFor(selectableFrameAssets)
final selectableFrameAssetsProvider = SelectableFrameAssetsProvider._();

/// S-06a フレーム選択タブ用の選択可能な素材一覧。

final class SelectableFrameAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Asset>>,
          List<Asset>,
          Stream<List<Asset>>
        >
    with $FutureModifier<List<Asset>>, $StreamProvider<List<Asset>> {
  /// S-06a フレーム選択タブ用の選択可能な素材一覧。
  SelectableFrameAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectableFrameAssetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectableFrameAssetsHash();

  @$internal
  @override
  $StreamProviderElement<List<Asset>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Asset>> create(Ref ref) {
    return selectableFrameAssets(ref);
  }
}

String _$selectableFrameAssetsHash() =>
    r'12b047d467813b108db2f74fa2fb4ca1a31bed51';

/// S-06a スタンプ選択タブ用の選択可能な素材一覧。

@ProviderFor(selectableStampAssets)
final selectableStampAssetsProvider = SelectableStampAssetsProvider._();

/// S-06a スタンプ選択タブ用の選択可能な素材一覧。

final class SelectableStampAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Asset>>,
          List<Asset>,
          Stream<List<Asset>>
        >
    with $FutureModifier<List<Asset>>, $StreamProvider<List<Asset>> {
  /// S-06a スタンプ選択タブ用の選択可能な素材一覧。
  SelectableStampAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectableStampAssetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectableStampAssetsHash();

  @$internal
  @override
  $StreamProviderElement<List<Asset>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Asset>> create(Ref ref) {
    return selectableStampAssets(ref);
  }
}

String _$selectableStampAssetsHash() =>
    r'33c4730cb33c70b310bf07c1a4b650672266862a';
