import 'package:flutter/foundation.dart';

/// redirect 再評価用の `ChangeNotifier`。認証状態・起動完了・オンボーディング完了の
/// 変化を `ref.listen` で合成して通知する(design.md「GoRouterルーティング設計」準拠)。
class GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
