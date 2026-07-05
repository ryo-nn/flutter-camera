// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
/// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
/// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
///
/// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
/// 非nullは既存マイパターンの更新・削除を表す。

@ProviderFor(PatternEditController)
final patternEditControllerProvider = PatternEditControllerFamily._();

/// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
/// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
/// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
///
/// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
/// 非nullは既存マイパターンの更新・削除を表す。
final class PatternEditControllerProvider
    extends $AsyncNotifierProvider<PatternEditController, void> {
  /// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
  /// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
  /// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
  ///
  /// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
  /// 非nullは既存マイパターンの更新・削除を表す。
  PatternEditControllerProvider._({
    required PatternEditControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'patternEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patternEditControllerHash();

  @override
  String toString() {
    return r'patternEditControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PatternEditController create() => PatternEditController();

  @override
  bool operator ==(Object other) {
    return other is PatternEditControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patternEditControllerHash() =>
    r'8d1d2101647d398e7c6dfe99c3882f8fa5a13748';

/// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
/// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
/// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
///
/// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
/// 非nullは既存マイパターンの更新・削除を表す。

final class PatternEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PatternEditController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String?
        > {
  PatternEditControllerFamily._()
    : super(
        retry: null,
        name: r'patternEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
  /// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
  /// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
  ///
  /// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
  /// 非nullは既存マイパターンの更新・削除を表す。

  PatternEditControllerProvider call(String? patternId) =>
      PatternEditControllerProvider._(argument: patternId, from: this);

  @override
  String toString() => r'patternEditControllerProvider';
}

/// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
/// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
/// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
///
/// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
/// 非nullは既存マイパターンの更新・削除を表す。

abstract class _$PatternEditController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String?;
  String? get patternId => _$args;

  FutureOr<void> build(String? patternId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// S-06「複製」導線で選択されたプリセットの初期値の受け渡し
/// (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を初期値とした
/// 新規作成)」準拠)。
///
/// `/patterns/new` ルート(実装済み `app_router.dart`)は `extra` を渡さないため、
/// S-06 が本プロバイダーへ複製元パターンをセットしてから遷移し、S-06a が
/// 読み取り後に [clear] する(design.mdに配置の明記が無いための実装判断。notes参照)。

@ProviderFor(PatternDuplicateSource)
final patternDuplicateSourceProvider = PatternDuplicateSourceProvider._();

/// S-06「複製」導線で選択されたプリセットの初期値の受け渡し
/// (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を初期値とした
/// 新規作成)」準拠)。
///
/// `/patterns/new` ルート(実装済み `app_router.dart`)は `extra` を渡さないため、
/// S-06 が本プロバイダーへ複製元パターンをセットしてから遷移し、S-06a が
/// 読み取り後に [clear] する(design.mdに配置の明記が無いための実装判断。notes参照)。
final class PatternDuplicateSourceProvider
    extends $NotifierProvider<PatternDuplicateSource, Pattern?> {
  /// S-06「複製」導線で選択されたプリセットの初期値の受け渡し
  /// (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を初期値とした
  /// 新規作成)」準拠)。
  ///
  /// `/patterns/new` ルート(実装済み `app_router.dart`)は `extra` を渡さないため、
  /// S-06 が本プロバイダーへ複製元パターンをセットしてから遷移し、S-06a が
  /// 読み取り後に [clear] する(design.mdに配置の明記が無いための実装判断。notes参照)。
  PatternDuplicateSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patternDuplicateSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patternDuplicateSourceHash();

  @$internal
  @override
  PatternDuplicateSource create() => PatternDuplicateSource();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Pattern? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Pattern?>(value),
    );
  }
}

String _$patternDuplicateSourceHash() =>
    r'd0879db578359d8c265470bdb8332a7db507e4e8';

/// S-06「複製」導線で選択されたプリセットの初期値の受け渡し
/// (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を初期値とした
/// 新規作成)」準拠)。
///
/// `/patterns/new` ルート(実装済み `app_router.dart`)は `extra` を渡さないため、
/// S-06 が本プロバイダーへ複製元パターンをセットしてから遷移し、S-06a が
/// 読み取り後に [clear] する(design.mdに配置の明記が無いための実装判断。notes参照)。

abstract class _$PatternDuplicateSource extends $Notifier<Pattern?> {
  Pattern? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Pattern?, Pattern?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Pattern?, Pattern?>,
              Pattern?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
