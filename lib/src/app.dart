import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/billing/presentation/billing_session_provider.dart';
import 'package:flutter_camera/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリのルートWidget。`goRouterProvider` を watch して `MaterialApp.router` を構成する。
/// (design.md アプリアーキテクチャ設計 ディレクトリ構造: `app.dart` の責務)
///
/// `billingSessionProvider` を常駐watchし、認証状態の変化にRevenueCat SDKの
/// configure/logIn/logOut を追従させる
/// (design.md 第9章「課金(IAP)・ペイウォール設計 による変更」: goRouterProviderと同じ常駐パターン)。
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(billingSessionProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'flutter-camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
