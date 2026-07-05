import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/presentation/sign_in_screen.dart';
import 'package:flutter_camera/src/features/billing/presentation/paywall_screen.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_video.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_screen.dart';
import 'package:flutter_camera/src/features/camera/presentation/video_preview_screen.dart';
import 'package:flutter_camera/src/features/editor/presentation/edit_preview_screen.dart';
import 'package:flutter_camera/src/features/history/presentation/post_history_screen.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:flutter_camera/src/features/patterns/presentation/pattern_edit_screen.dart';
import 'package:flutter_camera/src/features/patterns/presentation/pattern_list_screen.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_camera/src/features/posting/presentation/post_compose_screen.dart';
import 'package:flutter_camera/src/features/sns_accounts/presentation/instagram_pro_guide_screen.dart';
import 'package:flutter_camera/src/features/sns_accounts/presentation/sns_accounts_screen.dart';
import 'package:flutter_camera/src/features/startup/app_startup_provider.dart';
import 'package:flutter_camera/src/features/startup/presentation/splash_screen.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_camera/src/routing/go_router_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// アプリ全体で単一の root Navigator を使う(StatefulShellRoute は採用しない。
/// design.md 画面設計・UIフロー章「画面遷移図」の方針改訂を参照)。
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// GoRouter 生成(redirect / refreshListenable 配線)。
/// (design.md アプリアーキテクチャ設計「GoRouterルーティング設計」
/// + 第9章「リテンション機能設計 による変更」の redirect 改訂を反映した最終形)
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refresh = GoRouterRefreshNotifier();
  ref.onDispose(refresh.dispose);
  // redirect 再評価契機の合成: 認証状態・起動処理の完了・オンボーディング完了
  ref.listen(authStateChangesProvider, (_, _) => refresh.notify());
  ref.listen(appStartupProvider, (_, _) => refresh.notify());
  ref.listen(onboardingStateProvider, (_, _) => refresh.notify());

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    navigatorKey: rootNavigatorKey,
    refreshListenable: refresh,
    redirect: (context, state) {
      final startup = ref.read(appStartupProvider);
      final loc = state.matchedLocation;
      // 1. 起動処理が未完了なら splash に固定
      if (startup.isLoading || startup.hasError) {
        return loc == AppRoute.splash.path ? null : AppRoute.splash.path;
      }
      final onboarded = ref.read(onboardingStateProvider);
      final signedIn = ref.read(authStateChangesProvider).value != null;
      // オンボーディング配下で未認証アクセスを許可するルート
      final inOnboardingFlow = loc == AppRoute.onboarding.path ||
          loc == AppRoute.onboardingInstagramGuide.path;
      // 2. オンボーディング未完了なら /onboarding 配下以外を /onboarding に固定
      if (!onboarded) {
        return inOnboardingFlow ? null : AppRoute.onboarding.path;
      }
      // 3. 未ログインなら /sign-in に固定(オンボーディング配下ガイドのみ例外。
      //    /onboarding 本体を例外に含めると、オンボーディング完了後も
      //    現在地に留まれてしまい S-02 から遷移できなくなる)
      if (!signedIn) {
        return (loc == AppRoute.signIn.path ||
                loc == AppRoute.onboardingInstagramGuide.path)
            ? null
            : AppRoute.signIn.path;
      }
      // 4. ログイン済みが公開ルートに居たら /home へ
      final public = {
        AppRoute.splash.path,
        AppRoute.onboarding.path,
        AppRoute.onboardingInstagramGuide.path,
        AppRoute.signIn.path,
      };
      if (public.contains(loc)) return AppRoute.home.path;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            // matchedLocation: /onboarding/instagram-guide
            path: 'instagram-guide',
            name: AppRoute.onboardingInstagramGuide.name,
            builder: (context, state) => const InstagramProGuideScreen(
              mode: InstagramProGuideMode.onboarding,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.signIn.path,
        name: AppRoute.signIn.name,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const CameraScreen(),
        routes: [
          GoRoute(
            // matchedLocation: /home/edit
            path: 'edit',
            name: AppRoute.editPreview.name,
            redirect: (context, state) =>
                state.extra is CapturedPhoto ? null : AppRoute.home.path,
            builder: (context, state) => EditPreviewScreen(
              capturedPhoto: state.extra! as CapturedPhoto,
            ),
            routes: [
              GoRoute(
                // matchedLocation: /home/edit/post
                path: 'post',
                name: AppRoute.postCompose.name,
                redirect: (context, state) =>
                    state.extra is PostMedia ? null : AppRoute.home.path,
                builder: (context, state) =>
                    PostComposeScreen(media: state.extra! as PostMedia),
              ),
            ],
          ),
          GoRoute(
            // matchedLocation: /home/video
            // S-05v 動画プレビュー画面(フォトライブラリ取り込み・動画撮影モード追加分)。
            // S-07(postCompose)へは `postCompose` の名前解決でpushするため、
            // `edit` の子ルートとして定義する必要はない(既存の `edit` ネストは
            // 変更しない)。
            path: 'video',
            name: AppRoute.videoPreview.name,
            redirect: (context, state) =>
                state.extra is CapturedVideo ? null : AppRoute.home.path,
            builder: (context, state) => VideoPreviewScreen(
              capturedVideo: state.extra! as CapturedVideo,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.patterns.path,
        name: AppRoute.patterns.name,
        builder: (context, state) => const PatternListScreen(),
        routes: [
          GoRoute(
            // matchedLocation: /patterns/new
            path: 'new',
            name: AppRoute.patternNew.name,
            builder: (context, state) => const PatternEditScreen(),
          ),
          GoRoute(
            // matchedLocation: /patterns/:patternId
            path: ':patternId',
            name: AppRoute.patternEdit.name,
            builder: (context, state) => PatternEditScreen(
              patternId: state.pathParameters['patternId'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.history.path,
        name: AppRoute.history.name,
        builder: (context, state) => const PostHistoryScreen(),
      ),
      GoRoute(
        path: AppRoute.snsAccounts.path,
        name: AppRoute.snsAccounts.name,
        builder: (context, state) => const SnsAccountsScreen(),
        routes: [
          GoRoute(
            // matchedLocation: /settings/sns/instagram-guide
            path: 'instagram-guide',
            name: AppRoute.instagramProGuide.name,
            builder: (context, state) => const InstagramProGuideScreen(
              mode: InstagramProGuideMode.settings,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.plan.path,
        name: AppRoute.plan.name,
        // 第9章 追補「プレミアムパターンのロックタイルタップ(S-04/S-06)」準拠:
        // タップしたpatternIdを `extra`(String?)で受け取り、ペイウォールの
        // 訴求文脈(「『◯◯』はProプラン限定パターンです」)に用いる。
        // extraを渡さない他の遷移元(S-07上限到達等)ではnullのまま従来表示。
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PaywallScreen(
            patternId: state.extra is String ? state.extra as String : null,
          ),
        ),
      ),
    ],
  );
}
