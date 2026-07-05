import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_id_service.g.dart';

/// 無料枠X投稿のデバイス単位管理向けの端末識別子取得サービス
/// (quota章「デバイス単位の無料枠管理」節。`functions/src/sns/publishPost/quotaX.ts`
/// の `reserveXQuota` がfreeプランのXターゲット選択時に `deviceId`/`platform` を用いて
/// 1端末1アカウントの占有チェックを行う)。
///
/// - iOS: `device_info_plus`(公式パッケージ)の `IosDeviceInfo.identifierForVendor`。
/// - Android: 既存依存の `android_id` パッケージ(`AndroidId.getId()`)を用いる。
///   `device_info_plus` の `AndroidDeviceInfo.id` は `Build.ID`(OSビルドID。
///   同一OSビルドの全端末で同一値になり得る)であり端末固有値ではないため、
///   Android側の識別子取得には使用しない(design.md「端末識別子取得方針」節の
///   明記どおり)。
///
/// 取得不可時(非対応プラットフォーム・プラグイン例外等)は `null` を返す。
/// フォールバック値の生成や例外の握り潰し先の変更は行わず、`null` のまま
/// 呼び出し元(`postComposeControllerProvider.submit`)へ渡し、サーバー側の
/// 既存エラー(`deviceId is required for free plan X posting` 等)に
/// ハンドリングを委ねる(`post_compose_controller.dart` のdocコメント準拠)。
class DeviceIdService {
  const DeviceIdService();

  /// 生の端末識別子(TLS上のonCallで送信する。ハッシュ化は行わない。
  /// サーバー側で `SHA-256(DEVICE_ID_PEPPER + rawId)` によりハッシュ化される
  /// 設計のため、クライアントはハッシュ化しない生値を返す)。
  Future<String?> getDeviceId() async {
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          final info = await DeviceInfoPlugin().iosInfo;
          return info.identifierForVendor;
        case TargetPlatform.android:
          return await const AndroidId().getId();
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// `snsPublishPost` の入力 `platform?: 'ios' | 'android'`
  /// (`functions/src/sns/publishPost/quotaX.ts` の `ReserveXQuotaParams.platform`)
  /// と一致させる値。
  String? getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return null;
    }
  }
}

@Riverpod(keepAlive: true)
DeviceIdService deviceIdService(Ref ref) => const DeviceIdService();
