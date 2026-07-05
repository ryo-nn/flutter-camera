import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_state_provider.g.dart';

/// オンボーディング完了フラグの保持(design.md アプリアーキテクチャ設計
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `build()` は永続化復元前の安全な既定値 `false` を返す。実際の復元は
/// `appStartupProvider` が起動時に一度だけ [restore] を呼んで行う
/// (design.md「GoRouterルーティング設計」: redirect 再評価契機の一つとして
/// 本プロバイダーの変化を `ref.listen` する)。
@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  @override
  bool build() => false;

  /// `appStartupProvider` 専用。永続化済みの完了フラグを起動時に反映する
  /// (自身は永続化を行わない。復元のみ)。
  void restore(bool completed) {
    state = completed;
  }

  /// S-02「はじめる」「次へ(最終ページ)」「スキップ」いずれからも呼ばれる。
  /// 状態更新後の永続化のみを行い、画面遷移は行わない
  /// (design.md「splash/onboarding の画面側で context.go による明示的な遷移は
  /// 行わない」方針: 遷移は redirect が本プロバイダーの変化を検知して行う)。
  Future<void> complete() async {
    state = true;
    await ref.read(onboardingRepositoryProvider).setCompleted();
  }
}
