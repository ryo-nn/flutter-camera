// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_post_guide_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 初回投稿ガイドの表示判定(投稿実績+ローカルskipフラグ。design.md 第9章
/// 「アーキテクチャへの追補」プロバイダー追加表 準拠)。
///
/// `null` = 非表示。camera feature(S-04)は本プロバイダーをwatchし、
/// [FirstPostGuideOverlay] / [FirstPostGuideHighlight]
/// (`presentation/widgets/first_post_guide_overlay.dart`)でオーバーレイと
/// ハイライト対象を切り替える。プリセットタイルタップ時は
/// `advanceToShutterStep()` を呼ぶ(design.md「3ステップのオーバーレイ:
/// ①プリセットを選んでみましょう → ②シャッターで撮影 → ③撮影後は自然遷移に委ねる」)。
///
/// NOTE(統合フェーズ確認事項): `history` feature の
/// `postHistoryRepositoryProvider` の実装クラスに、当月ではなく「投稿実績が
/// 1件でも存在するか」を返す `Future<bool> hasAnyPost(String uid)`
/// (design.md 第9章: `posts.where('userId'==uid).limit(1)` の存在チェック
/// 相当)の実装を依頼している(coreChangeRequests参照)。

@ProviderFor(FirstPostGuide)
final firstPostGuideProvider = FirstPostGuideProvider._();

/// 初回投稿ガイドの表示判定(投稿実績+ローカルskipフラグ。design.md 第9章
/// 「アーキテクチャへの追補」プロバイダー追加表 準拠)。
///
/// `null` = 非表示。camera feature(S-04)は本プロバイダーをwatchし、
/// [FirstPostGuideOverlay] / [FirstPostGuideHighlight]
/// (`presentation/widgets/first_post_guide_overlay.dart`)でオーバーレイと
/// ハイライト対象を切り替える。プリセットタイルタップ時は
/// `advanceToShutterStep()` を呼ぶ(design.md「3ステップのオーバーレイ:
/// ①プリセットを選んでみましょう → ②シャッターで撮影 → ③撮影後は自然遷移に委ねる」)。
///
/// NOTE(統合フェーズ確認事項): `history` feature の
/// `postHistoryRepositoryProvider` の実装クラスに、当月ではなく「投稿実績が
/// 1件でも存在するか」を返す `Future<bool> hasAnyPost(String uid)`
/// (design.md 第9章: `posts.where('userId'==uid).limit(1)` の存在チェック
/// 相当)の実装を依頼している(coreChangeRequests参照)。
final class FirstPostGuideProvider
    extends $NotifierProvider<FirstPostGuide, FirstPostGuideStep?> {
  /// 初回投稿ガイドの表示判定(投稿実績+ローカルskipフラグ。design.md 第9章
  /// 「アーキテクチャへの追補」プロバイダー追加表 準拠)。
  ///
  /// `null` = 非表示。camera feature(S-04)は本プロバイダーをwatchし、
  /// [FirstPostGuideOverlay] / [FirstPostGuideHighlight]
  /// (`presentation/widgets/first_post_guide_overlay.dart`)でオーバーレイと
  /// ハイライト対象を切り替える。プリセットタイルタップ時は
  /// `advanceToShutterStep()` を呼ぶ(design.md「3ステップのオーバーレイ:
  /// ①プリセットを選んでみましょう → ②シャッターで撮影 → ③撮影後は自然遷移に委ねる」)。
  ///
  /// NOTE(統合フェーズ確認事項): `history` feature の
  /// `postHistoryRepositoryProvider` の実装クラスに、当月ではなく「投稿実績が
  /// 1件でも存在するか」を返す `Future<bool> hasAnyPost(String uid)`
  /// (design.md 第9章: `posts.where('userId'==uid).limit(1)` の存在チェック
  /// 相当)の実装を依頼している(coreChangeRequests参照)。
  FirstPostGuideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstPostGuideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstPostGuideHash();

  @$internal
  @override
  FirstPostGuide create() => FirstPostGuide();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirstPostGuideStep? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirstPostGuideStep?>(value),
    );
  }
}

String _$firstPostGuideHash() => r'39cab70f7994baf013a8887f17566e7981a7947b';

/// 初回投稿ガイドの表示判定(投稿実績+ローカルskipフラグ。design.md 第9章
/// 「アーキテクチャへの追補」プロバイダー追加表 準拠)。
///
/// `null` = 非表示。camera feature(S-04)は本プロバイダーをwatchし、
/// [FirstPostGuideOverlay] / [FirstPostGuideHighlight]
/// (`presentation/widgets/first_post_guide_overlay.dart`)でオーバーレイと
/// ハイライト対象を切り替える。プリセットタイルタップ時は
/// `advanceToShutterStep()` を呼ぶ(design.md「3ステップのオーバーレイ:
/// ①プリセットを選んでみましょう → ②シャッターで撮影 → ③撮影後は自然遷移に委ねる」)。
///
/// NOTE(統合フェーズ確認事項): `history` feature の
/// `postHistoryRepositoryProvider` の実装クラスに、当月ではなく「投稿実績が
/// 1件でも存在するか」を返す `Future<bool> hasAnyPost(String uid)`
/// (design.md 第9章: `posts.where('userId'==uid).limit(1)` の存在チェック
/// 相当)の実装を依頼している(coreChangeRequests参照)。

abstract class _$FirstPostGuide extends $Notifier<FirstPostGuideStep?> {
  FirstPostGuideStep? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FirstPostGuideStep?, FirstPostGuideStep?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FirstPostGuideStep?, FirstPostGuideStep?>,
              FirstPostGuideStep?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
