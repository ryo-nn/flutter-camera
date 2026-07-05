import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SnsConnection.isConnected', () {
    test('statusがconnectedならtrueを返す', () {
      const connection = SnsConnection(
        provider: SnsProvider.instagram,
        status: SnsConnectionStatus.connected,
      );

      expect(connection.isConnected, isTrue);
    });

    for (final status in [
      SnsConnectionStatus.expired,
      SnsConnectionStatus.revoked,
      SnsConnectionStatus.error,
    ]) {
      test('statusが$statusならfalseを返す', () {
        final connection = SnsConnection(
          provider: SnsProvider.instagram,
          status: status,
        );

        expect(connection.isConnected, isFalse);
      });
    }
  });

  group('SnsConnection.requiresProAccountSwitch', () {
    test('Instagram・connected・isProAccount=falseの組み合わせでtrueを返す', () {
      const connection = SnsConnection(
        provider: SnsProvider.instagram,
        status: SnsConnectionStatus.connected,
        isProAccount: false,
      );

      expect(connection.requiresProAccountSwitch, isTrue);
    });

    test('Instagram・connected・isProAccount=trueならfalseを返す', () {
      const connection = SnsConnection(
        provider: SnsProvider.instagram,
        status: SnsConnectionStatus.connected,
        isProAccount: true,
        accountType: 'BUSINESS',
      );

      expect(connection.requiresProAccountSwitch, isFalse);
    });

    test('Instagram・connected・isProAccount=nullならfalseを返す(未確定は警告しない)', () {
      const connection = SnsConnection(
        provider: SnsProvider.instagram,
        status: SnsConnectionStatus.connected,
      );

      expect(connection.requiresProAccountSwitch, isFalse);
    });

    test('未連携(expired)ならisProAccount=falseでもfalseを返す', () {
      const connection = SnsConnection(
        provider: SnsProvider.instagram,
        status: SnsConnectionStatus.expired,
        isProAccount: false,
      );

      expect(connection.requiresProAccountSwitch, isFalse);
    });

    test('XはisProAccount=falseでも常にfalseを返す(Instagram限定の判定のため)', () {
      const connection = SnsConnection(
        provider: SnsProvider.x,
        status: SnsConnectionStatus.connected,
        isProAccount: false,
      );

      expect(connection.requiresProAccountSwitch, isFalse);
    });
  });
}
