import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/history/data/firestore_post_history_repository.dart';
import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_post_guide_provider.g.dart';

/// S-04 初回投稿ガイド(コーチマーク)のステップ
/// (design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」参照)。
enum FirstPostGuideStep {
  /// 「プリセットを選んでみましょう」(カルーセルのプリセットタイルをハイライト)
  selectPattern,

  /// 「シャッターで撮影」(シャッターボタンをハイライト)
  shutter,
}

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
@riverpod
class FirstPostGuide extends _$FirstPostGuide {
  @override
  FirstPostGuideStep? build() {
    // build() は同期必須のため、非表示(既定)を返しつつ非同期で判定する
    // (onboardingStateProvider の restore と同型のパターン)。
    _evaluate();
    return null;
  }

  Future<void> _evaluate() async {
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;

    final onboardingRepository = ref.read(onboardingRepositoryProvider);
    if (await onboardingRepository.isFirstPostGuideSkipped()) return;

    final hasPosted =
        await ref.read(postHistoryRepositoryProvider).hasAnyPost(uid);
    if (hasPosted) return;

    state = FirstPostGuideStep.selectPattern;
  }

  /// プリセットタイルタップ時にcamera feature(S-04)から呼ぶ。
  void advanceToShutterStep() {
    if (state == FirstPostGuideStep.selectPattern) {
      state = FirstPostGuideStep.shutter;
    }
  }

  /// 「スキップ」操作(以後非表示。shared_preferencesへ永続化)。
  Future<void> skip() async {
    state = null;
    await ref.read(onboardingRepositoryProvider).skipFirstPostGuide();
  }
}
