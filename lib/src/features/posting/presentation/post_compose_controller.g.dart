// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_compose_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// S-07 一括投稿の実行(アップロード→Functions 呼び出し)を担うController。
/// (design.md アーキテクチャ章 `postComposeControllerProvider` 準拠。
/// state は投稿完了後の `postId`。UIはこれを [postStatusProvider] の
/// familyキーとして渡し、投稿処理モーダルで進捗を購読する)
///
/// design.mdのプロバイダー依存表は `snsConnectionsProvider`(sns_accounts機能)への
/// 依存も挙げているが、接続状態に応じたチェックボックス無効化はUI(画面)側の責務とし、
/// controllerは画面側で検証済みの `instagram`/`x` フラグをそのまま受け取る設計とした
/// (sns_accounts機能のドメイン型に対する詳細フィールド名の推測依存を業務ロジックに
/// 持ち込まないための判断。notes参照)。

@ProviderFor(PostComposeController)
final postComposeControllerProvider = PostComposeControllerProvider._();

/// S-07 一括投稿の実行(アップロード→Functions 呼び出し)を担うController。
/// (design.md アーキテクチャ章 `postComposeControllerProvider` 準拠。
/// state は投稿完了後の `postId`。UIはこれを [postStatusProvider] の
/// familyキーとして渡し、投稿処理モーダルで進捗を購読する)
///
/// design.mdのプロバイダー依存表は `snsConnectionsProvider`(sns_accounts機能)への
/// 依存も挙げているが、接続状態に応じたチェックボックス無効化はUI(画面)側の責務とし、
/// controllerは画面側で検証済みの `instagram`/`x` フラグをそのまま受け取る設計とした
/// (sns_accounts機能のドメイン型に対する詳細フィールド名の推測依存を業務ロジックに
/// 持ち込まないための判断。notes参照)。
final class PostComposeControllerProvider
    extends $AsyncNotifierProvider<PostComposeController, String?> {
  /// S-07 一括投稿の実行(アップロード→Functions 呼び出し)を担うController。
  /// (design.md アーキテクチャ章 `postComposeControllerProvider` 準拠。
  /// state は投稿完了後の `postId`。UIはこれを [postStatusProvider] の
  /// familyキーとして渡し、投稿処理モーダルで進捗を購読する)
  ///
  /// design.mdのプロバイダー依存表は `snsConnectionsProvider`(sns_accounts機能)への
  /// 依存も挙げているが、接続状態に応じたチェックボックス無効化はUI(画面)側の責務とし、
  /// controllerは画面側で検証済みの `instagram`/`x` フラグをそのまま受け取る設計とした
  /// (sns_accounts機能のドメイン型に対する詳細フィールド名の推測依存を業務ロジックに
  /// 持ち込まないための判断。notes参照)。
  PostComposeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postComposeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postComposeControllerHash();

  @$internal
  @override
  PostComposeController create() => PostComposeController();
}

String _$postComposeControllerHash() =>
    r'0f4167f728596ac7563add523a7169bf174f2f62';

/// S-07 一括投稿の実行(アップロード→Functions 呼び出し)を担うController。
/// (design.md アーキテクチャ章 `postComposeControllerProvider` 準拠。
/// state は投稿完了後の `postId`。UIはこれを [postStatusProvider] の
/// familyキーとして渡し、投稿処理モーダルで進捗を購読する)
///
/// design.mdのプロバイダー依存表は `snsConnectionsProvider`(sns_accounts機能)への
/// 依存も挙げているが、接続状態に応じたチェックボックス無効化はUI(画面)側の責務とし、
/// controllerは画面側で検証済みの `instagram`/`x` フラグをそのまま受け取る設計とした
/// (sns_accounts機能のドメイン型に対する詳細フィールド名の推測依存を業務ロジックに
/// 持ち込まないための判断。notes参照)。

abstract class _$PostComposeController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
