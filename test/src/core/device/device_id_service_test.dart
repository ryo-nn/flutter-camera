import 'package:flutter/foundation.dart';
import 'package:flutter_camera/src/core/device/device_id_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('DeviceIdService.getPlatform', () {
    test('iOSでは snsPublishPost 契約に合わせて "ios" を返す', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(const DeviceIdService().getPlatform(), 'ios');
    });

    test('Androidでは snsPublishPost 契約に合わせて "android" を返す', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(const DeviceIdService().getPlatform(), 'android');
    });

    test('iOS/Android以外ではnullを返す', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(const DeviceIdService().getPlatform(), isNull);
    });
  });

  group('DeviceIdService.getDeviceId', () {
    test('iOS/Android以外ではnullを返す', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(await const DeviceIdService().getDeviceId(), isNull);
    });

    // テスト環境ではandroid_id/device_info_plusのネイティブ実装が存在しないため
    // プラットフォームチャネル呼び出しは失敗する。DeviceIdServiceはこれを
    // 捕捉してnullを返す仕様(design.md「限界の明示」節: 取得不可時は
    // フォールバック値を作らずサーバー側の既存エラーに委ねる方針)であることを
    // 確認する。
    test(
      'Androidでプラットフォームチャネルが利用できない場合は例外を握り潰しnullを返す',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        expect(await const DeviceIdService().getDeviceId(), isNull);
      },
    );

    test(
      'iOSでプラットフォームチャネルが利用できない場合は例外を握り潰しnullを返す',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        expect(await const DeviceIdService().getDeviceId(), isNull);
      },
    );
  });
}
