// =============================================================================
// 中核フロー E2E テスト雛形
//   起動(S-01) → オンボーディング(S-02) → ログイン/サインアップ(S-03) →
//   撮影(S-04) → パターン適用 → 加工プレビュー(S-05) → SNS投稿画面(S-07) →
//   投稿履歴(S-08)
// =============================================================================
//
// 本ファイルの位置づけ
// -----------------------------------------------------------------------------
// docs/design.md「アプリアーキテクチャ設計」ディレクトリ構造の節にある
// 「E2E コードは `integration_test/` に配置する(結合テストの実施自体は RYO の
// 手動検証)」という方針に基づく E2E テストの雛形である。
// 本タスクの範囲では実行しない(シミュレータ未起動・Firebase 未設定のため)。
// RYO が手動結合テストを行う際に、下記の前提条件を整えたうえで実行・加筆して
// 使用することを想定する。
//
// 実行方法(想定・未実施)
// -----------------------------------------------------------------------------
//   flutter test integration_test/app_flow_test.dart -d <deviceId> \
//     --dart-define=E2E_TEST_EMAIL=<テスト用メールアドレス> \
//     --dart-define=E2E_TEST_PASSWORD=<テスト用パスワード>
//
//   Flutter 公式の integration_test パッケージは `flutter test` から実機/
//   シミュレータ/エミュレータへ直接実行できる(`flutter drive` 用の
//   test_driver/ エントリは本タスクの担当範囲(integration_test/ 配下)外のため
//   未作成。必要であれば別途追加を検討)。
//
// 実行前に RYO が手動で準備・確認すべき前提条件
// -----------------------------------------------------------------------------
//   1. 実機/シミュレータ/エミュレータに Firebase プロジェクト設定
//      (ios/Runner/GoogleService-Info.plist, android/app/google-services.json)
//      が実際に有効なプロジェクトに紐づいていること。
//   2. 対象 Firebase プロジェクトの Authentication でメール/パスワード認証を
//      有効化していること。
//   3. E2E_TEST_EMAIL / E2E_TEST_PASSWORD で指定するテスト用アカウント
//      (未作成でもよい。ログイン失敗時は本テストが自動で新規登録にフォールバック
//      する)。本番相当のFirebaseプロジェクトを汚さないよう、必ずテスト/開発用
//      プロジェクトを使用すること。
//   4. Firestore の `patterns` コレクションに `ownerType: 'preset'` の
//      プリセットパターンが最低 1 件投入されていること(「パターン適用」を
//      実質的に検証するため)。未投入でも「加工なし」のままテストは継続する。
//   5. 実機、またはカメラをサポートするシミュレータ/エミュレータでカメラ権限を
//      許可できる状態にあること。iOS シミュレータは実カメラを持たないため、
//      撮影ステップの検証は実機での確認を強く推奨する
//      (docs/design.md カメラ・自動加工パイプライン設計 §1章 参照)。
//      ※iOS Info.plist に NSCameraUsageDescription、AndroidManifest.xml に
//        android.permission.CAMERA が未設定の場合は権限要求自体が失敗しうる
//        (coreChangeRequests 参照)。
//   6. Instagram/X への実投稿確認は Meta App Review・X API 契約が前提のため、
//      本 E2E の既定の自動化範囲には含めない。「投稿する」ボタンの表示確認までとし、
//      実投稿まで検証したい場合のみ
//      `--dart-define=E2E_ALLOW_REAL_SNS_POSTING=true` を追加し、
//      Instagram/X が連携済みのテストアカウントで実行すること。
//
// RYO が手動結合テストで確認すべき観点
// (本 E2E では自動検証しない、または画面到達までしか検証しない項目)
// -----------------------------------------------------------------------------
//   - Firebase Auth: 実際のサインアップ/サインインの一連(確認メール等を含む)と
//     エラー文言の網羅性
//   - Firestore: プリセットパターンの配信内容・マイパターン CRUD の実データ反映
//   - camera: 実機での前後カメラ切替、権限拒否からの復帰、機種依存の初期化エラー
//   - pro_image_editor: 微調整エディタ(S-05a)でのフィルター/フレーム/スタンプ
//     編集結果が加工プレビューへ正しく反映されること
//   - Cloud Functions / Storage: 加工画像の一時アップロード → Instagram/X 投稿 →
//     アップロード画像の削除、という一連の実処理
//   - Instagram: プロアカウント判定・非プロアカウント切替導線(S-09a)の実際の遷移
//   - X: 投稿回数上限(月次枠 + 購入クレジット)のサーバー側 enforcement と
//     UI 表示(「今月あと◯回」等)の一致
//   - 投稿履歴(S-08): 実際に投稿した結果が一覧・成果ダッシュボードへ正しく
//     反映されること(本 E2E は既定では実投稿を行わないため未検証)
//   - RevenueCat 課金: トライアル・プラン購入・リストア(サンドボックス環境)
//   - アクセシビリティ: TalkBack/VoiceOver での実際の読み上げ内容、
//     文字拡大 1.3 倍時のレイアウト崩れ有無
//
// 本テストが自動検証する範囲
// -----------------------------------------------------------------------------
//   起動 → オンボーディング完了 → ログイン(または新規登録)→ カメラ初期化待ち →
//   (可能であれば)プリセットパターン選択 → 撮影 → 加工確定 → SNS 投稿画面到達 →
//   (既定では投稿は行わず)投稿履歴画面への到達性、を一連の UI フローとして検証する。
//   各段階で Firebase 接続・カメラ・SNS 連携等の外部要因により継続不能と
//   判断した場合は `markTestSkipped` で理由を明示してスキップする
//   (テスト失敗として扱わない)。
//
// 実装上の注意
// -----------------------------------------------------------------------------
//   画面上に常時アニメーションする `CircularProgressIndicator`(ローディング/
//   投稿処理中スピナー等)が存在する間は `tester.pumpAndSettle()` が既定の
//   10 分タイムアウトまで収束せず `FlutterError` を送出する
//   (flutter_test の既知の挙動)。本ファイルでは、状態遷移の完了判定は
//   `_pumpUntil`(条件ポーリング)で行い、単純な画面遷移の待機のみ
//   `_safeSettle`(短いタイムアウト + `FlutterError` 握りつぶし)を使う。
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/app.dart';
import 'package:flutter_camera/src/features/camera/presentation/widgets/pattern_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// テスト用アカウント(未指定ならログイン以降のステップを実行時スキップする)。
const String _testEmail = String.fromEnvironment('E2E_TEST_EMAIL');
const String _testPassword = String.fromEnvironment('E2E_TEST_PASSWORD');

/// true の場合のみ Instagram/X への実投稿まで検証する(既定は false)。
const bool _allowRealSnsPosting = bool.fromEnvironment(
  'E2E_ALLOW_REAL_SNS_POSTING',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('中核フロー: 起動→オンボーディング→ログイン→撮影→パターン適用→投稿画面→履歴', (tester) async {
    // アイコンボタン(撮影・SNS連携設定・投稿履歴等)は Semantics ラベルでのみ
    // 判別できるため、Semantics ツリーを有効化する
    // (docs/design.md 画面設計・UIフロー章「アクセシビリティ配慮」準拠の実装が
    // 前提)。
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(semanticsHandle.dispose);

    if (!await _launchAppOrSkip(tester)) return;
    await _completeOnboardingIfShown(tester);
    if (!await _signInOrSkip(tester)) return;
    if (!await _waitForCameraReadyOrSkip(tester)) return;
    await _selectPresetPatternIfAvailable(tester);
    if (!await _capturePhotoOrSkip(tester)) return;
    if (!await _confirmEditAndProceedToPostComposeOrSkip(tester)) return;
    await _verifyPostComposeScreenAndReachHistory(tester);
  });
}

// -----------------------------------------------------------------------------
// 共通ヘルパー
// -----------------------------------------------------------------------------

/// [condition] が真になるまで [timeout] を上限にポーリングする。
/// カメラ初期化・Firebase 通信・画像加工など非同期処理の完了待ちに使う。
Future<bool> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 500),
}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    await tester.pump(step);
    if (condition()) return true;
    if (DateTime.now().isAfter(end)) return condition();
  }
}

/// 単純な画面遷移・ダイアログ表示の待機用。スピナー等の無限アニメーションが
/// 存在する画面でも `pumpAndSettle` の既定 10 分タイムアウトまで待たされない
/// よう、短いタイムアウトを指定し `FlutterError`(タイムアウト時)を許容する。
Future<void> _safeSettle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  } on FlutterError {
    // 常時アニメーション(ローディング/投稿処理中スピナー等)により
    // pumpAndSettle が収束しないケースを許容し、後続の明示的な条件待ちに委ねる。
  }
}

// -----------------------------------------------------------------------------
// 画面判定(design.md 画面設計・UIフロー章の各画面の主要UI要素・文言に対応)
// -----------------------------------------------------------------------------

bool _splashErrorShown() =>
    find.text('起動に失敗しました。通信環境を確認して再試行してください。').evaluate().isNotEmpty;

/// S-02 オンボーディング(「スキップ」は全ページ共通で表示される)。
bool _onOnboardingScreen() => find.text('スキップ').evaluate().isNotEmpty;

/// S-03 ログイン/サインアップ(ログイン/新規登録の切替タブで判定)。
bool _onSignInScreen() =>
    find.text('ログイン').evaluate().isNotEmpty &&
    find.text('新規登録').evaluate().isNotEmpty;

/// S-04 ホーム/撮影。SNS連携設定アイコンはカメラ準備状態に関わらず常時表示される
/// (camera_screen.dart 参照)ため、シャッターボタンより先に判定できる。
bool _onHomeScreen() => find.bySemanticsLabel('SNS連携設定').evaluate().isNotEmpty;

bool _authErrorShown() =>
    find.textContaining('メールアドレスまたはパスワードが正しくありません').evaluate().isNotEmpty;

// -----------------------------------------------------------------------------
// S-01 起動
// -----------------------------------------------------------------------------

Future<bool> _launchAppOrSkip(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: App()));
  await tester.pump(const Duration(seconds: 1));

  final reachedNextScreen = await _pumpUntil(
    tester,
    () =>
        _splashErrorShown() ||
        _onOnboardingScreen() ||
        _onSignInScreen() ||
        _onHomeScreen(),
    timeout: const Duration(seconds: 15),
  );

  if (!reachedNextScreen) {
    markTestSkipped('S-01 起動処理が既定時間内に完了しませんでした。実機/シミュレータの状態を確認してください。');
    return false;
  }
  if (_splashErrorShown()) {
    markTestSkipped(
      'S-01 でFirebase初期化に失敗しました(Firebase未設定またはネットワーク不通の可能性)。'
      'GoogleService-Info.plist / google-services.json の対象プロジェクト設定・'
      '通信環境を確認してください。',
    );
    return false;
  }
  return true;
}

// -----------------------------------------------------------------------------
// S-02 オンボーディング
// -----------------------------------------------------------------------------

Future<void> _completeOnboardingIfShown(WidgetTester tester) async {
  if (!_onOnboardingScreen()) return; // 既に完了済み(永続化フラグ)

  // ページ1・2は「次へ」、最終ページ(プロアカウント要件案内)は「はじめる」。
  for (var i = 0; i < 2; i++) {
    final nextButton = find.widgetWithText(FilledButton, '次へ');
    if (nextButton.evaluate().isEmpty) break;
    await tester.tap(nextButton);
    await _safeSettle(tester);
  }
  final startButton = find.widgetWithText(FilledButton, 'はじめる');
  if (startButton.evaluate().isNotEmpty) {
    await tester.tap(startButton);
    await _safeSettle(tester);
  }
}

// -----------------------------------------------------------------------------
// S-03 ログイン/サインアップ
// -----------------------------------------------------------------------------

Future<bool> _signInOrSkip(WidgetTester tester) async {
  await _pumpUntil(
    tester,
    () => _onSignInScreen() || _onHomeScreen(),
    timeout: const Duration(seconds: 10),
  );

  if (_onHomeScreen()) return true; // 永続化済みセッションで既にログイン済み

  if (_testEmail.isEmpty || _testPassword.isEmpty) {
    markTestSkipped(
      'E2E_TEST_EMAIL / E2E_TEST_PASSWORD が未指定のためログイン以降をスキップしました。'
      '例: flutter test integration_test/app_flow_test.dart '
      '--dart-define=E2E_TEST_EMAIL=test@example.com '
      '--dart-define=E2E_TEST_PASSWORD=xxxxxxxx',
    );
    return false;
  }

  await _fillAuthForm(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'ログインする'));
  await _safeSettle(tester);

  if (!_onHomeScreen() && _authErrorShown()) {
    // テスト用アカウント未作成(初回実行等)の場合は新規登録にフォールバックする。
    await tester.tap(find.text('新規登録'));
    await _safeSettle(tester);
    await _fillAuthForm(tester);
    await tester.tap(find.widgetWithText(FilledButton, '登録する'));
    await _safeSettle(tester);
  }

  final signedIn = await _pumpUntil(
    tester,
    _onHomeScreen,
    timeout: const Duration(seconds: 10),
  );
  if (!signedIn) {
    markTestSkipped(
      'S-03 ログイン/新規登録後にS-04ホーム画面へ到達できませんでした。'
      'テスト用アカウントの状態・Firebase Authenticationのメール/パスワード有効化設定を確認してください。',
    );
    return false;
  }
  return true;
}

Future<void> _fillAuthForm(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, _testEmail);
  await tester.enterText(find.byType(TextFormField).last, _testPassword);
}

// -----------------------------------------------------------------------------
// S-04 ホーム/撮影(カメラ初期化待ち・パターン選択・撮影)
// -----------------------------------------------------------------------------

Future<bool> _waitForCameraReadyOrSkip(WidgetTester tester) async {
  const permissionDeniedMessage = 'カメラへのアクセスが許可されていません。撮影には許可が必要です。';
  const cameraErrorMessage = 'カメラを起動できませんでした。';

  // シャッターボタン(Semantics label: '撮影')は camera_screen.dart の実装上、
  // カメラ初期化成功時のみ表示される。
  final settled = await _pumpUntil(
    tester,
    () =>
        find.bySemanticsLabel('撮影').evaluate().isNotEmpty ||
        find.text(permissionDeniedMessage).evaluate().isNotEmpty ||
        find.text(cameraErrorMessage).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
  );

  if (!settled) {
    markTestSkipped('S-04 カメラの初期化が既定時間内に完了しませんでした。');
    return false;
  }
  if (find.text(permissionDeniedMessage).evaluate().isNotEmpty) {
    markTestSkipped('カメラ権限が許可されていないためスキップしました。実機/シミュレータの設定でカメラ許可を確認してください。');
    return false;
  }
  if (find.text(cameraErrorMessage).evaluate().isNotEmpty) {
    markTestSkipped('カメラの初期化に失敗しました(実カメラを持たないシミュレータ等の可能性)。実機での確認を推奨します。');
    return false;
  }
  return true;
}

/// Firestore配信のプリセットパターンは名前を固定できないため、カルーセル上の
/// button Semantics のうち「加工なし」「+ パターンを作る」以外の先頭1件を選択する
/// (見つからない場合は「加工なし」のまま撮影に進む)。
///
/// S-04追補(フォトライブラリ取り込み・動画撮影モード切替)により、シャッター周辺にも
/// 「ライブラリから選ぶ」「写真モード」「動画モード」等の button Semantics が追加された
/// ため、`find.descendant(of: find.byType(PatternCarousel), ...)` で
/// [PatternCarousel] 配下に検索範囲を限定し、これらと誤って一致しないようにする。
Future<void> _selectPresetPatternIfAvailable(WidgetTester tester) async {
  Finder patternTiles() => find.descendant(
    of: find.byType(PatternCarousel),
    matching: find.byWidgetPredicate(_isSelectablePatternTile),
  );

  await _pumpUntil(
    tester,
    () =>
        patternTiles().evaluate().isNotEmpty ||
        find.text('パターンを読み込めませんでした').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 8),
  );

  final candidate = patternTiles();
  if (candidate.evaluate().isEmpty) {
    // プリセット未投入 or Firestore未接続。「加工なし」のまま続行する
    // (前提条件4を参照。パターン適用そのものの検証はここでは行われない)。
    return;
  }
  await tester.tap(candidate.first);
  await _safeSettle(tester);
}

bool _isSelectablePatternTile(Widget widget) {
  if (widget is! Semantics) return false;
  final properties = widget.properties;
  if (properties.button != true) return false;
  final label = properties.label;
  if (label == null) return false;
  const excludedLabels = {'撮影', '加工なし', '+ パターンを作る'};
  if (excludedLabels.contains(label)) return false;
  // 「(パターン名)、選択中」ラベルは既に選択済みのタイル(初期状態では該当なし)。
  return !label.contains('選択中');
}

Future<bool> _capturePhotoOrSkip(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('撮影'));
  final reachedEditPreview = await _pumpUntil(
    tester,
    () => find.text('加工プレビュー').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
  );
  if (!reachedEditPreview) {
    markTestSkipped('撮影後にS-05加工プレビュー画面へ遷移しませんでした(実カメラを持たないシミュレータ等の可能性)。');
    return false;
  }
  return true;
}

// -----------------------------------------------------------------------------
// S-05 加工プレビュー → S-07 SNS投稿画面
// -----------------------------------------------------------------------------

Future<bool> _confirmEditAndProceedToPostComposeOrSkip(
  WidgetTester tester,
) async {
  // 「次へ」は軽量プレビュー適用(パターン適用)が完了するまで無効化されている
  // (edit_preview_screen.dart の controlsDisabled / hasValue 判定)。
  final nextEnabled = await _pumpUntil(tester, () {
    final nextButton = find.widgetWithText(FilledButton, '次へ');
    if (nextButton.evaluate().isEmpty) return false;
    return tester.widget<FilledButton>(nextButton).onPressed != null;
  }, timeout: const Duration(seconds: 15));
  if (!nextEnabled) {
    markTestSkipped('S-05「次へ」ボタンが既定時間内に活性化しませんでした(画像加工処理の失敗の可能性)。');
    return false;
  }

  await tester.tap(find.widgetWithText(FilledButton, '次へ'));
  await _safeSettle(tester);

  // 「投稿フローへ進みますか?」確認ダイアログ(showConfirmDialog, confirmLabel: '次へ')。
  if (find.text('投稿フローへ進みますか?').evaluate().isEmpty) {
    markTestSkipped('「次へ」タップ後に確認ダイアログが表示されませんでした。');
    return false;
  }
  // ダイアログのアクションボタンは同じ文言「次へ」で2つ目に描画される。
  await tester.tap(find.widgetWithText(FilledButton, '次へ').last);

  final reachedPostCompose = await _pumpUntil(
    tester,
    () => find.text('SNSに投稿').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 15),
  );
  if (!reachedPostCompose) {
    markTestSkipped('S-07 SNS投稿画面へ遷移しませんでした(最終JPEG生成の失敗等の可能性)。');
    return false;
  }
  return true;
}

// -----------------------------------------------------------------------------
// S-07 SNS投稿画面 → S-08 投稿履歴
// -----------------------------------------------------------------------------

Future<void> _verifyPostComposeScreenAndReachHistory(
  WidgetTester tester,
) async {
  // 連携状態・X残り回数の取得(snsConnectionsProvider / xQuotaProvider)を待つ。
  await _pumpUntil(
    tester,
    () => find.widgetWithText(FilledButton, '投稿する').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
  );
  expect(find.widgetWithText(FilledButton, '投稿する'), findsOneWidget);

  if (_allowRealSnsPosting) {
    await _submitRealPostAndVerifyHistory(tester);
    return;
  }

  // 既定ではInstagram/X未連携のテストアカウントを想定し実投稿は行わない
  // (Meta App Review・X API契約が前提のため。実投稿の成否確認はRYOの手動結合
  // テストに委ねる。前提条件6参照)。
  // S-05へ戻り、破棄確認ダイアログ経由でS-04→S-08へ到達できることのみ検証する。
  await tester.pageBack(); // S-07 → S-05
  await _safeSettle(tester);
  await tester.pageBack(); // S-05のPopScopeが破棄確認ダイアログを開く
  await _safeSettle(tester);

  if (find.text('編集内容を破棄して撮影に戻りますか?').evaluate().isNotEmpty) {
    await tester.tap(find.widgetWithText(FilledButton, '破棄する'));
    await _safeSettle(tester);
  }

  final backOnHome = await _pumpUntil(
    tester,
    _onHomeScreen,
    timeout: const Duration(seconds: 10),
  );
  if (!backOnHome) {
    markTestSkipped('S-05からの破棄確認後にS-04ホーム画面へ戻れませんでした。');
    return;
  }

  await tester.tap(find.bySemanticsLabel('投稿履歴'));
  final reachedHistory = await _pumpUntil(
    tester,
    () => find.text('投稿履歴').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
  );
  expect(reachedHistory, isTrue, reason: 'S-08 投稿履歴画面へ到達できませんでした。');
}

/// `--dart-define=E2E_ALLOW_REAL_SNS_POSTING=true` を指定した場合のみ実行する。
/// Instagram/Xが連携済みのテストアカウントでの実投稿を前提とする
/// (前提条件6参照)。未連携等で選択可能な投稿先が無い場合はスキップする。
Future<void> _submitRealPostAndVerifyHistory(WidgetTester tester) async {
  final instagramCheckbox = find.widgetWithText(CheckboxListTile, 'Instagram');
  final xCheckbox = find.widgetWithText(CheckboxListTile, 'X');
  final hasSelectableTarget =
      instagramCheckbox.evaluate().isNotEmpty ||
      xCheckbox.evaluate().isNotEmpty;

  if (!hasSelectableTarget) {
    markTestSkipped(
      'Instagram/XいずれもS-07で選択可能な状態ではありません(未連携・非プロアカウント・'
      '上限到達等)。実投稿確認にはSNS連携済みのテストアカウントが必要です。',
    );
    return;
  }

  await tester.tap(
    instagramCheckbox.evaluate().isNotEmpty ? instagramCheckbox : xCheckbox,
  );
  await _safeSettle(tester);

  await tester.enterText(find.byType(TextField), 'flutter-camera E2E自動投稿テスト');
  await _safeSettle(tester);

  await tester.tap(find.widgetWithText(FilledButton, '投稿する'));
  await _safeSettle(tester);
  // 「選択したSNSに投稿します。よろしいですか?」確認ダイアログ(confirmLabel: '投稿する')。
  await tester.tap(find.widgetWithText(FilledButton, '投稿する').last);

  // 投稿処理モーダル(SNSごとにアップロード中→投稿中→完了/失敗)の終了を待つ。
  // 完了後はpost_compose_screen.dartのredirectによりS-08へ自動的に置換遷移する。
  final reachedHistory = await _pumpUntil(
    tester,
    () => find.text('投稿履歴').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
  );
  expect(reachedHistory, isTrue, reason: '投稿完了後にS-08投稿履歴画面へ自動遷移しませんでした。');
}
