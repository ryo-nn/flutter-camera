import 'dart:async';

import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/app_auth_service.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/functions_sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sns_connect_controller.g.dart';

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
@riverpod
class SnsConnectController extends _$SnsConnectController {
  @override
  FutureOr<void> build(SnsProvider provider) {}

  /// 認可コード取得(flutter_appauth)→ Cloud Functionsでのトークン交換を実行する。
  Future<void> connect() async {
    final appAuthService = ref.read(appAuthServiceProvider);
    final repository = ref.read(snsAccountRepositoryProvider);

    state = const AsyncLoading<void>();
    try {
      final result = provider == SnsProvider.instagram
          ? await appAuthService.authorizeInstagram()
          : await appAuthService.authorizeX();

      if (provider == SnsProvider.instagram) {
        await repository.exchangeInstagramCode(
          code: result.authorizationCode,
          redirectUri: result.redirectUri,
        );
      } else {
        await repository.exchangeXCode(
          code: result.authorizationCode,
          codeVerifier: result.codeVerifier ?? '',
          redirectUri: result.redirectUri,
        );
      }
      state = const AsyncData<void>(null);
    } on SnsAuthorizationCancelledException {
      state = const AsyncData<void>(null);
      rethrow;
    } catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }

  /// 連携解除(`snsDisconnect`)を実行する。
  Future<void> disconnect() async {
    final repository = ref.read(snsAccountRepositoryProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => repository.disconnect(provider));
  }
}
