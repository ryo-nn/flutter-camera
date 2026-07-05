import 'dart:async';

import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_controller.g.dart';

/// メール/パスワードのサインイン・サインアップ実行(S-03)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「signInControllerProvider」)
///
/// UI は本Controllerの `AsyncValue<void>` を watch し、
/// loading = 実行ボタン内スピナー+入力無効化、
/// error = フォーム直下にインライン表示する
/// (design.md 画面設計・UIフロー章 S-03 状態表: 「文言はフォーム直下にインライン表示」)。
/// 共通の `error_listener.dart`(SnackBar表示)はS-03では使用しない。
@riverpod
class SignInController extends _$SignInController {
  @override
  Future<void> build() async {}

  /// ログイン実行。
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email, password: password),
    );
  }

  /// 新規登録実行(Firebase Authアカウント作成 + `users/{uid}` プロフィール作成)。
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmailAndPassword(email: email, password: password),
    );
  }
}
