import 'dart:async';

// auth featureは並列実装中のため、design.mdの命名規約(authStateChangesProviderは
// auth/data/firebase_auth_repository.dartに定義)に従って参照する
// (posting/data/firestore_x_quota_repository.dart と同一の参照方法。notes参照)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/billing/data/revenuecat_billing_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_session_provider.g.dart';

/// 認証状態に追従してRevenueCat SDKの configure/logIn/logOut を実行する常駐プロバイダー
/// (design.md 課金章「クライアント統合」節: 「`billingSessionProvider`(keepAlive)が
/// `authStateChangesProvider` を `ref.listen` し、サインイン→`ensureSession(uid)`、
/// サインアウト→`clearSession()` を実行する」準拠)。
///
/// `app.dart` で `ref.watch(billingSessionProvider)` により常駐させる
/// (`goRouterProvider` と同じ常駐パターン。design.md同節末尾の記載準拠)。
@Riverpod(keepAlive: true)
void billingSession(Ref ref) {
  ref.listen(
    authStateChangesProvider,
    (previous, next) {
      final billingService = ref.read(billingServiceProvider);
      // `AsyncValue.valueOrNull` は本プロジェクトのriverpodバージョンに存在しないため
      // `.value`(nullable getter)を使う(editor/presentation/edit_preview_screen.dart
      // で確認済み)。
      final user = next.value;
      if (user != null) {
        unawaited(billingService.ensureSession(user.uid));
      } else {
        // clearSession側でisConfigured判定を行うため、未configure時の
        // 無用なlogOut呼び出しにはならない(revenuecat_billing_service.dart参照)。
        unawaited(billingService.clearSession());
      }
    },
    // 起動時点で既にログイン済みの場合(アプリ再起動等)にも確実に
    // configure/logInを実行するため、購読開始時点の現在値でも一度発火させる。
    fireImmediately: true,
  );
}
