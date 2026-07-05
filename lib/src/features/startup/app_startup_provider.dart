import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_camera/firebase_options.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/utils/app_logger.dart';
import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup_provider.g.dart';

/// アプリ起動処理(design.md アプリアーキテクチャ設計「アーキテクチャ全体像」
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `main.dart` は `Firebase.initializeApp` 前の最小処理のみを行い、
/// Firebase初期化・オンボーディングフラグ復元は本プロバイダーに集約する。
/// 完了(`AsyncData`)まで S-01 スプラッシュが表示され続け、`app_router.dart` の
/// redirect が `startup.isLoading || startup.hasError` を判定して遷移を止める。
///
/// 小規模のため domain/data 層を設けない(startup feature の設計方針)。
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // App Check の有効化(design.md quota章「App Check の Functions 側 enforce」節:
    // 全onCall関数が `enforceAppCheck: true` のため、これを行わないと本番で
    // Callable Functionsが全滅する)。
    //
    // RYO作業(コンソール側の登録。コードでは対応不可):
    // 1. Firebase Console > App Check で iOS/Androidアプリを登録する。
    // 2. iOS: 実機で `AppleAppAttestProvider`(iOS 14+)が使えない場合は
    //    自動的に `AppleDeviceCheckProvider` にフォールバックする
    //    (`AppleAppAttestWithDeviceCheckFallbackProvider` の既定挙動)。
    //    Apple Developer側でApp Attest向けの追加設定は不要(Firebase SDKが処理)。
    // 3. Android: Play Integrity APIをGoogle Play Consoleでプロジェクトに
    //    紐づけ、Play Integrity の利用を有効化する。
    // 4. デバッグ実行時(kDebugMode)はデバッグプロバイダを使用する。初回起動時に
    //    デバッグトークンがログ(Xcode/Logcat)に出力されるため、
    //    Firebase Console > App Check > Apps > デバッグトークンを管理 に登録する
    //    (実機・シミュレータ双方で個別に必要)。
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
    } catch (e, stackTrace) {
      // activate失敗でアプリを起動不能にしない(ログのみ。design.md「失敗時は
      // ログのみ」方針)。App Check未有効のままだとonCall呼び出しは
      // `enforceAppCheck: true` により拒否されるが、それ自体は各Functions呼び出し側の
      // 既存エラーハンドリングに委ねる。
      AppLogger.error(
        'FirebaseAppCheck.activate に失敗しました',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final completed = await ref.read(onboardingRepositoryProvider).isCompleted();
    ref.read(onboardingStateProvider.notifier).restore(completed);
  } on AppException {
    rethrow;
  } catch (e) {
    // S-01 error 状態(design.md 画面設計・UIフロー章 S-01 参照):
    // 「Firebase初期化失敗・ネットワーク不通時」を単一の NetworkException に
    // 集約する(SDK例外を data 層で AppException に変換して throw する
    // エラーハンドリング方針に準拠。表示文言は error_mapper.dart に一元化)。
    throw NetworkException('起動処理に失敗しました: $e');
  }
}
