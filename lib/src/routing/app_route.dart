/// ルート名(`AppRoute.xxx.name`)・パス定数の単一情報源。
/// (design.md 画面設計・UIフロー章「GoRouterルーティング設計」+ 第9章 追補による変更点 準拠)
///
/// UIフロー章の方針により `StatefulShellRoute.indexedStack`(ボトムナビ)は採用せず、
/// S-04(ホーム/撮影)を単一のハブとするpush型遷移で統一する。
enum AppRoute {
  splash('/splash'),
  onboarding('/onboarding'),

  /// リテンション機能設計 による追加(要件§5「獲得装置としてオンボーディングに統合」)。
  /// `/onboarding` の子ルート。未認証アクセス可。
  onboardingInstagramGuide('/onboarding/instagram-guide'),

  signIn('/sign-in'),

  home('/home'),
  editPreview('/home/edit'),
  postCompose('/home/edit/post'),

  /// フォトライブラリ取り込み・動画撮影モード追加による新設(S-05v 動画プレビュー画面)。
  videoPreview('/home/video'),

  patterns('/patterns'),
  patternNew('/patterns/new'),
  patternEdit('/patterns/:patternId'),

  history('/history'),

  snsAccounts('/settings/sns'),
  instagramProGuide('/settings/sns/instagram-guide'),

  /// 課金(IAP)・ペイウォール設計 による追加。root push(fullscreenDialog)。
  plan('/plan');

  const AppRoute(this.path);

  /// GoRoute の `path`(子ルートは親からの相対パスに読み替えて使用する)。
  final String path;
}
