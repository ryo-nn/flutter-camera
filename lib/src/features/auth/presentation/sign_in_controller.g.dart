// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// メール/パスワードのサインイン・サインアップ実行(S-03)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「signInControllerProvider」)
///
/// UI は本Controllerの `AsyncValue<void>` を watch し、
/// loading = 実行ボタン内スピナー+入力無効化、
/// error = フォーム直下にインライン表示する
/// (design.md 画面設計・UIフロー章 S-03 状態表: 「文言はフォーム直下にインライン表示」)。
/// 共通の `error_listener.dart`(SnackBar表示)はS-03では使用しない。

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// メール/パスワードのサインイン・サインアップ実行(S-03)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「signInControllerProvider」)
///
/// UI は本Controllerの `AsyncValue<void>` を watch し、
/// loading = 実行ボタン内スピナー+入力無効化、
/// error = フォーム直下にインライン表示する
/// (design.md 画面設計・UIフロー章 S-03 状態表: 「文言はフォーム直下にインライン表示」)。
/// 共通の `error_listener.dart`(SnackBar表示)はS-03では使用しない。
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, void> {
  /// メール/パスワードのサインイン・サインアップ実行(S-03)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「signInControllerProvider」)
  ///
  /// UI は本Controllerの `AsyncValue<void>` を watch し、
  /// loading = 実行ボタン内スピナー+入力無効化、
  /// error = フォーム直下にインライン表示する
  /// (design.md 画面設計・UIフロー章 S-03 状態表: 「文言はフォーム直下にインライン表示」)。
  /// 共通の `error_listener.dart`(SnackBar表示)はS-03では使用しない。
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'3ac88de0a17d62f7b1ca4a24342c84a2620c49e5';

/// メール/パスワードのサインイン・サインアップ実行(S-03)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「signInControllerProvider」)
///
/// UI は本Controllerの `AsyncValue<void>` を watch し、
/// loading = 実行ボタン内スピナー+入力無効化、
/// error = フォーム直下にインライン表示する
/// (design.md 画面設計・UIフロー章 S-03 状態表: 「文言はフォーム直下にインライン表示」)。
/// 共通の `error_listener.dart`(SnackBar表示)はS-03では使用しない。

abstract class _$SignInController extends $AsyncNotifier<void> {
  FutureOr<void> build();
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
    element.handleCreate(ref, build);
  }
}
