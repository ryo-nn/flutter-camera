import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart';
import 'package:flutter_camera/src/features/billing/data/revenuecat_billing_service.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_repository.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_service.dart';
import 'package:flutter_camera/src/features/billing/presentation/purchase_controller.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class MockBillingService extends Mock implements BillingService {}

class MockBillingRepository extends Mock implements BillingRepository {}

final _fakePackage = Package(
  'pro_monthly',
  PackageType.custom,
  const StoreProduct(
    'fcam_pro_1m',
    'Pro月額プラン',
    'Pro',
    980,
    '¥980',
    'JPY',
  ),
  const PresentedOfferingContext('default', null, null),
);

void main() {
  late MockBillingService billingService;
  late MockBillingRepository billingRepository;
  late ProviderContainer container;

  setUp(() {
    billingService = MockBillingService();
    billingRepository = MockBillingRepository();
    container = ProviderContainer(
      overrides: [
        billingServiceProvider.overrideWithValue(billingService),
        billingRepositoryProvider.overrideWithValue(billingRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('purchase', () {
    test('成功時はBillingService.purchase→refreshCustomerの順で呼びAsyncDataになる', () async {
      when(() => billingService.purchase(_fakePackage)).thenAnswer((_) async {});
      when(() => billingRepository.refreshCustomer()).thenAnswer(
        (_) async => const BillingRefreshResult(
          plan: Plan.pro,
          isTrial: false,
          postCredits: 0,
        ),
      );

      container.read(purchaseControllerProvider);
      await container
          .read(purchaseControllerProvider.notifier)
          .purchase(_fakePackage);

      final state = container.read(purchaseControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
      verifyInOrder([
        () => billingService.purchase(_fakePackage),
        () => billingRepository.refreshCustomer(),
      ]);
    });

    test('キャンセル時はBillingException(cancelled:true)のAsyncErrorになる', () async {
      when(
        () => billingService.purchase(_fakePackage),
      ).thenThrow(const BillingException('purchase cancelled', cancelled: true));

      container.read(purchaseControllerProvider);
      await container
          .read(purchaseControllerProvider.notifier)
          .purchase(_fakePackage);

      final state = container.read(purchaseControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<BillingException>().having((e) => e.cancelled, 'cancelled', isTrue),
      );
      verifyNever(() => billingRepository.refreshCustomer());
    });

    test('失敗時はBillingExceptionのAsyncErrorになりrefreshCustomerは呼ばれない', () async {
      when(
        () => billingService.purchase(_fakePackage),
      ).thenThrow(const BillingException('purchase failed: unknown'));

      container.read(purchaseControllerProvider);
      await container
          .read(purchaseControllerProvider.notifier)
          .purchase(_fakePackage);

      final state = container.read(purchaseControllerProvider);
      expect(state.hasError, isTrue);
      verifyNever(() => billingRepository.refreshCustomer());
    });
  });

  group('restore', () {
    test('復元ありの場合はtrueを返しrefreshCustomerを呼ぶ', () async {
      when(() => billingService.restore()).thenAnswer((_) async => true);
      when(() => billingRepository.refreshCustomer()).thenAnswer(
        (_) async => const BillingRefreshResult(
          plan: Plan.light,
          isTrial: false,
          postCredits: 0,
        ),
      );

      container.read(purchaseControllerProvider);
      final restored = await container
          .read(purchaseControllerProvider.notifier)
          .restore();

      expect(restored, isTrue);
      expect(container.read(purchaseControllerProvider).hasError, isFalse);
      verify(() => billingRepository.refreshCustomer()).called(1);
    });

    test('復元対象がない場合はfalseを返す', () async {
      when(() => billingService.restore()).thenAnswer((_) async => false);
      when(() => billingRepository.refreshCustomer()).thenAnswer(
        (_) async => const BillingRefreshResult(
          plan: Plan.free,
          isTrial: false,
          postCredits: 0,
        ),
      );

      container.read(purchaseControllerProvider);
      final restored = await container
          .read(purchaseControllerProvider.notifier)
          .restore();

      expect(restored, isFalse);
    });

    test('失敗時はfalseを返しAsyncErrorになる', () async {
      when(
        () => billingService.restore(),
      ).thenThrow(const BillingException('restore failed: unknown'));

      container.read(purchaseControllerProvider);
      final restored = await container
          .read(purchaseControllerProvider.notifier)
          .restore();

      expect(restored, isFalse);
      expect(container.read(purchaseControllerProvider).hasError, isTrue);
    });
  });
}
