// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sns_connect_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
/// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
/// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
///
/// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
/// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
/// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
/// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
/// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
/// 共通経路にのみ流れ、キャンセルと二重表示にならない)。

@ProviderFor(SnsConnectController)
final snsConnectControllerProvider = SnsConnectControllerFamily._();

/// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
/// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
/// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
///
/// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
/// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
/// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
/// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
/// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
/// 共通経路にのみ流れ、キャンセルと二重表示にならない)。
final class SnsConnectControllerProvider
    extends $AsyncNotifierProvider<SnsConnectController, void> {
  /// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
  /// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
  /// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
  ///
  /// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
  /// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
  /// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
  /// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
  /// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
  /// 共通経路にのみ流れ、キャンセルと二重表示にならない)。
  SnsConnectControllerProvider._({
    required SnsConnectControllerFamily super.from,
    required SnsProvider super.argument,
  }) : super(
         retry: null,
         name: r'snsConnectControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$snsConnectControllerHash();

  @override
  String toString() {
    return r'snsConnectControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SnsConnectController create() => SnsConnectController();

  @override
  bool operator ==(Object other) {
    return other is SnsConnectControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$snsConnectControllerHash() =>
    r'ee753baf9713b390a3569c1bbf12a983417ac77f';

/// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
/// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
/// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
///
/// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
/// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
/// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
/// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
/// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
/// 共通経路にのみ流れ、キャンセルと二重表示にならない)。

final class SnsConnectControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SnsConnectController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          SnsProvider
        > {
  SnsConnectControllerFamily._()
    : super(
        retry: null,
        name: r'snsConnectControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
  /// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
  /// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
  ///
  /// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
  /// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
  /// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
  /// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
  /// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
  /// 共通経路にのみ流れ、キャンセルと二重表示にならない)。

  SnsConnectControllerProvider call(SnsProvider provider) =>
      SnsConnectControllerProvider._(argument: provider, from: this);

  @override
  String toString() => r'snsConnectControllerProvider';
}

/// S-09 SNSアカウント連携設定画面の連携・解除実行を担うController
/// (design.md アーキテクチャ章 `snsConnectControllerProvider`・family(`SnsProvider`)
/// 「連携(認可コード取得→Functionsでトークン交換)/解除の実行」準拠)。
///
/// キャンセル(`SnsAuthorizationCancelledException`)は「エラー扱いにしない」
/// (design.md UIフロー章 S-09準拠)ため `state` を `AsyncError` にはせず、
/// 呼び出し元(画面)が個別にcatchして専用のSnackBarを出せるよう rethrow する
/// (画面側は `ref.read(...).connect()` を直接 await して try-on する設計。
/// これにより通常のエラーは `AsyncError` 経由で `ErrorMapper`/`listenAppError` の
/// 共通経路にのみ流れ、キャンセルと二重表示にならない)。

abstract class _$SnsConnectController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as SnsProvider;
  SnsProvider get provider => _$args;

  FutureOr<void> build(SnsProvider provider);
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
