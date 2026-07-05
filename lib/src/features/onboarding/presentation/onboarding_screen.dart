import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-02 オンボーディング(design.md 画面設計・UIフロー章 S-02 +
/// 第9章「オンボーディング改訂(初回セッション導線)」> 「S-02 オンボーディング画面の
/// 改訂」準拠)。
///
/// 3ページの横スワイプ `PageView`。「はじめる」「スキップ」は
/// `onboardingStateProvider.complete()` を呼ぶのみで、本画面から `context.go`
/// による明示的な画面遷移は行わない(遷移責務は `app_router.dart` の redirect に
/// 一元化する設計方針: design.md「GoRouterルーティング設計」参照)。
///
/// ページ3の「切り替え手順を見る」は例外で、`/onboarding/instagram-guide`
/// (オンボーディングフロー内の子ルート。redirect の未認証許可対象)への
/// 通常の push 遷移を行う。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 3;

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() {
    return ref.read(onboardingStateProvider.notifier).complete();
  }

  void _handleNext() {
    if (_currentPage == _pageCount - 1) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: const [
                _OnboardingPage(
                  icon: Icons.auto_awesome,
                  title: '撮って、選ぶだけ。パターンで自動加工',
                  body: 'プリセットを同梱。最初の1枚からいつもの加工。',
                ),
                _OnboardingPage(
                  icon: Icons.send_rounded,
                  title: 'InstagramとXへまとめて投稿',
                ),
                _OnboardingProAccountPage(),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: TextButton(
                onPressed: _complete,
                child: const Text('スキップ'),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PageIndicator(
                    currentPage: _currentPage,
                    pageCount: _pageCount,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _currentPage == _pageCount - 1 ? 'はじめる' : '次へ',
                    onPressed: _handleNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ページインジケータ(design.md UIフロー章「主要UI要素」: 「ページインジケータ」)。
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.pageCount});

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ページ ${currentPage + 1} / $pageCount',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// ページ1・2共通レイアウト。
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, this.body});

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 96, 32, 120),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (body != null) ...[
            const SizedBox(height: 16),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

/// ページ3: プロアカウント要件・X投稿上限の案内 + 切り替え手順導線
/// + 初回同時投稿保証の告知(design.md 第9章「S-02 オンボーディング画面の改訂」
/// 「プロアカウント切替ガイドの統合」準拠)。
class _OnboardingProAccountPage extends StatelessWidget {
  const _OnboardingProAccountPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 96, 32, 120),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.verified_user_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '連携の前に',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Instagramはプロアカウント(ビジネス/クリエイター)のみ投稿できます。'
            'Xへの投稿は1日の回数上限があります。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextButton(
            // オンボーディングフロー内の子ルート(未認証アクセス可)。
            // `app_router.dart` redirect の `inOnboardingFlow` 例外により
            // このページに留まったまま表示できる(design.md 第9章参照)。
            onPressed: () =>
                context.pushNamed(AppRoute.onboardingInstagramGuide.name),
            child: const Text('切り替え手順を見る'),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '初回は1回、Xにも無料で投稿できます',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
