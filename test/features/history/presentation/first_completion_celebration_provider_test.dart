import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/history/data/firestore_post_history_repository.dart';
import 'package:flutter_camera/src/features/history/domain/post_history_repository.dart';
import 'package:flutter_camera/src/features/history/presentation/first_completion_celebration_provider.dart';
import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class _MockPostHistoryRepository extends Mock
    implements PostHistoryRepository {}

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

const _dummyNotificationSettings = NotificationSettings(
  alert: AppleNotificationSetting.enabled,
  announcement: AppleNotificationSetting.disabled,
  authorizationStatus: AuthorizationStatus.authorized,
  badge: AppleNotificationSetting.enabled,
  carPlay: AppleNotificationSetting.disabled,
  lockScreen: AppleNotificationSetting.enabled,
  notificationCenter: AppleNotificationSetting.enabled,
  showPreviews: AppleShowPreviewSetting.always,
  timeSensitive: AppleNotificationSetting.disabled,
  criticalAlert: AppleNotificationSetting.disabled,
  sound: AppleNotificationSetting.enabled,
  providesAppNotificationSettings: AppleNotificationSetting.disabled,
);

Post _post({
  required String id,
  PostOverallStatus overallStatus = PostOverallStatus.succeeded,
}) {
  return Post(
    id: id,
    userId: 'u1',
    imagePath: 'users/u1/postImages/$id.jpg',
    caption: '',
    instagram: const PostTarget(
      provider: SnsProvider.instagram,
      selected: true,
      status: PostTargetStatus.succeeded,
    ),
    x: const PostTarget(
      provider: SnsProvider.x,
      selected: false,
      status: PostTargetStatus.skipped,
    ),
    overallStatus: overallStatus,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

/// 内部の非同期評価(`_evaluate()`)が完了するまで待つ(既存
/// `firebase_auth_repository_test.dart` の `await Future<void>.delayed(Duration.zero)`
/// パターンに倣う)。`_evaluate()` は
/// `onboardingRepository.isFirstCompletionCelebrationShown()` →
/// `postHistoryRepository.watchPostHistory().first` の順にawaitするため、
/// 2回分のマイクロタスクを空けて完了を待つ。
///
/// NOTE: `postHistoryProvider`(history/data/firestore_post_history_repository.dart。
/// autoDispose)は本provider([FirstCompletionCelebration])の実装が使用していないため、
/// 本ヘルパーからは触れない(触れると本テストが監視していないautoDisposeの
/// 破棄スケジューリングに巻き込まれ、`postHistoryProvider was disposed during
/// loading state` の非決定的な失敗を引き起こす)。
Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late _MockOnboardingRepository onboardingRepository;
  late _MockPostHistoryRepository postHistoryRepository;
  late _MockFirebaseMessaging firebaseMessaging;

  ProviderContainer makeContainer({
    required bool alreadyShown,
    required List<Post> posts,
  }) {
    onboardingRepository = _MockOnboardingRepository();
    postHistoryRepository = _MockPostHistoryRepository();
    firebaseMessaging = _MockFirebaseMessaging();

    when(
      () => onboardingRepository.isFirstCompletionCelebrationShown(),
    ).thenAnswer((_) async => alreadyShown);
    when(
      () => onboardingRepository.markFirstCompletionCelebrationShown(),
    ).thenAnswer((_) async {});
    when(
      () => postHistoryRepository.watchPostHistory(),
    ).thenAnswer((_) => Stream.value(posts));
    when(
      () => firebaseMessaging.requestPermission(),
    ).thenAnswer((_) async => _dummyNotificationSettings);

    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        postHistoryRepositoryProvider.overrideWithValue(
          postHistoryRepository,
        ),
        firebaseMessagingProvider.overrideWithValue(firebaseMessaging),
      ],
    );
    addTearDown(container.dispose);
    // firstCompletionCelebrationProvider・依存先の postHistoryProvider は
    // ともに autoDispose(実運用では `PostHistoryScreen` の `ref.watch` が
    // 購読し続けることで維持される)。`container.read` だけでは購読が残らず
    // テスト内の複数操作の間で破棄・再構築されてしまうため、本物のwatchと同様に
    // 購読を維持するリスナーを張っておく。
    container.listen(firstCompletionCelebrationProvider, (_, _) {});
    return container;
  }

  group('表示判定', () {
    test('初期値はnull(復元前の安全な既定値)', () {
      final container = makeContainer(alreadyShown: false, posts: const []);

      expect(container.read(firstCompletionCelebrationProvider), isNull);
    });

    test('表示済みフラグが立っている場合は非表示のまま', () async {
      final container = makeContainer(
        alreadyShown: true,
        posts: [_post(id: 'p1')],
      );

      container.read(firstCompletionCelebrationProvider);
      await _flush();

      expect(container.read(firstCompletionCelebrationProvider), isNull);
    });

    test('未表示かつ成功投稿が1件のみの場合はcompletionCardになる(=初回投稿が今回成功した)', () async {
      final container = makeContainer(
        alreadyShown: false,
        posts: [_post(id: 'p1')],
      );

      container.read(firstCompletionCelebrationProvider);
      await _flush();

      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.completionCard,
      );
    });

    test('成功投稿が2件以上の場合は非表示のまま(既に初回を消化済み)', () async {
      final container = makeContainer(
        alreadyShown: false,
        posts: [_post(id: 'p1'), _post(id: 'p2')],
      );

      container.read(firstCompletionCelebrationProvider);
      await _flush();

      expect(container.read(firstCompletionCelebrationProvider), isNull);
    });

    test('成功投稿が0件(投稿なし・全件失敗)の場合は非表示のまま', () async {
      final container = makeContainer(
        alreadyShown: false,
        posts: [_post(id: 'p1', overallStatus: PostOverallStatus.failed)],
      );

      container.read(firstCompletionCelebrationProvider);
      await _flush();

      expect(container.read(firstCompletionCelebrationProvider), isNull);
    });
  });

  group('ステップ遷移', () {
    late ProviderContainer container;

    setUp(() async {
      container = makeContainer(alreadyShown: false, posts: [_post(id: 'p1')]);
      container.read(firstCompletionCelebrationProvider);
      await _flush();
    });

    test('completionCard状態でadvanceToNotificationPermissionを呼ぶとnotificationPermissionへ進む', () {
      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();

      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.notificationPermission,
      );
    });

    test('requestNotificationPermissionはOSの許可を要求し、trialBannerへ進み、表示済みフラグを記録する', () async {
      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();

      await container
          .read(firstCompletionCelebrationProvider.notifier)
          .requestNotificationPermission();

      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.trialBanner,
      );
      verify(() => firebaseMessaging.requestPermission()).called(1);
      verify(
        () => onboardingRepository.markFirstCompletionCelebrationShown(),
      ).called(1);
    });

    test('skipNotificationPermissionはOSの許可を要求せずtrialBannerへ進み、表示済みフラグを記録する', () async {
      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();

      await container
          .read(firstCompletionCelebrationProvider.notifier)
          .skipNotificationPermission();

      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.trialBanner,
      );
      verifyNever(() => firebaseMessaging.requestPermission());
      verify(
        () => onboardingRepository.markFirstCompletionCelebrationShown(),
      ).called(1);
    });

    test('dismissTrialBannerはstateをnullに戻す', () async {
      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();
      await container
          .read(firstCompletionCelebrationProvider.notifier)
          .skipNotificationPermission();

      container
          .read(firstCompletionCelebrationProvider.notifier)
          .dismissTrialBanner();

      expect(container.read(firstCompletionCelebrationProvider), isNull);
    });

    test('completionCard以外の状態でadvanceToNotificationPermissionを呼んでも変化しない', () async {
      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();
      await container
          .read(firstCompletionCelebrationProvider.notifier)
          .skipNotificationPermission();

      container
          .read(firstCompletionCelebrationProvider.notifier)
          .advanceToNotificationPermission();

      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.trialBanner,
      );
    });

    test('notificationPermission状態でない場合はrequestNotificationPermissionを呼んでも許可要求しない', () async {
      // このsetUp直後はcompletionCard状態(advanceToNotificationPermission未実行)。
      await container
          .read(firstCompletionCelebrationProvider.notifier)
          .requestNotificationPermission();

      verifyNever(() => firebaseMessaging.requestPermission());
      expect(
        container.read(firstCompletionCelebrationProvider),
        FirstCompletionCelebrationStep.completionCard,
      );
    });
  });
}
