# リリース作業チェックリスト(RYO実施分)

コード実装・テスト・設計書は完了済み(design.md 第10〜11章参照)。本書は**私(RYO)以外には実行できない外部依存作業**を、実行順・コマンド付きで整理したもの。

進め方: 上から順に。1〜2が全ての前提。

**2026-07-05 確認・一部代行実施**: Firebase Consoleをブラウザで確認し、済み/未了を反映した。KMS作成・Storageルールデプロイ・cross-service IAM許可・igTempライフサイクル・DEVICE_ID_PEPPER生成はRYO承認のうえ代行実施済み(下記チェック参照)。

---

## 1. 課金アカウント(全Firebase作業の前提)

- [x] **確認済み**: Firebaseプロジェクト `flutter-camera-ryonn` は **Blazeプラン** 済み

## 2. Firebase 基盤設定

- [x] **確認済み**: Storage有効化済み(バケット `flutter-camera-ryonn.firebasestorage.app` 存在)
- [x] Firestoreルールはデプロイ済み(確認済み、実ルール内容が反映されている)
- [x] **代行実施済み**: Storageルールが未デプロイ(デフォルトの全面拒否テンプレートのまま)だったのを発見し、デプロイ実施:
  ```sh
  cd /Users/r/Source/ryo_nn
  firebase deploy --only storage --project flutter-camera-ryonn
  ```
- [x] **代行実施済み**: Storage→Firestore cross-service Rules(`hasActiveProPlan()`が参照)の
      IAM許可が未設定だったため、コンソール「問題を修正」→「権限を付与」で許可(RYO承認済み)
- [x] **代行実施済み**: igTemp/ ライフサイクル(1日で自動削除)を設定済み(RYO承認済み)
- [x] **確認済み**: Phone Auth(メール/パスワード・電話番号とも)有効化済み
- [x] **代行実施済み**: SMS Region Policyを「許可リスト: 日本(JP)のみ」に設定(RYO承認済み)
- [x] **代行実施済み**: Androidアプリに**デバッグ鍵**のSHA-1を登録済み(RYO承認済み):
      `22:67:C5:A2:AE:AA:31:65:CD:8C:0B:0E:3D:73:2F:03:45:37:8F:9F`
  - [ ] **未了**: **リリース署名鍵**のSHA-1は未作成・未登録。鍵生成・保管はRYO自身の判断で実施すること
        (紛失するとPlay Storeでの今後のアプリ更新が不可能になるため、生成・バックアップは意図的に代行していない):
    ```sh
    keytool -genkey -v -keystore ~/release-flutter-camera.jks -keyalg RSA \
      -keysize 2048 -validity 10000 -alias flutter-camera-release
    # 生成後、そのSHA-1/SHA-256をFirebase Console(プロジェクト設定 > Androidアプリ)と
    # App Check(Play Integrity)に追加登録し、android/key.properties + build.gradle.ktsの
    # signingConfigs.release を設定してから `flutter build appbundle --release` する
    ```
- [x] **代行実施済み**: App Check — iOS/Androidアプリとも登録完了(RYO承認済み)
  - Android: Play Integrity(デバッグ鍵SHA-256: `EF:6D:A9:CB:03:2E:2E:80:9B:41:EB:7F:C9:5A:68:20:BA:50:CC:99:98:F5:04:77:06:1B:DF:0D:CA:99:AA:82`)
  - iOS: App Attest(チームID: `LY354RVYHA`)
  - [ ] **未了**: デバッグトークンの追加登録(実機での動作確認時、初回起動ログに出力される
        トークンをコンソールへ追加すると、デバッグビルドでもCallable Functionsを呼べる)
  - [ ] **未了**: Androidの**リリース署名鍵**用SHA-256の追加登録(署名鍵確定後)
- [x] **代行実施済み**: KMS鍵(SNSトークン暗号化用)作成+権限付与(RYO承認済み):
      `projects/flutter-camera-ryonn/locations/asia-northeast1/keyRings/sns-tokens/cryptoKeys/token-key`
      (Functions実行SAへ cryptoKeyEncrypterDecrypter・serviceAccountTokenCreator 付与済み)

## 3. 外部サービスのキー取得

Meta/X/RevenueCat/App Store Connectはブラウザで未確認(これらのアカウント作成・審査申請は
性質上RYO本人の作業であり、代行・偵察のいずれも行っていない)。

- [ ] **Meta**: developers.facebook.com でアプリ作成(Instagram API with Instagram Login)。
      `instagram_business_basic` + `instagram_business_content_publish` の**アプリレビュー申請**
      (審査通過がリリース判定条件。審査中は開発モード+テスターで検証可)
- [ ] **X**: developer.x.com でアプリ作成(OAuth 2.0、従量課金の支払い設定)
- [ ] **RevenueCat**: プロジェクト作成、Entitlement `light`/`pro`、
      Product `fcam_light_1m` / `fcam_pro_1m` / `fcam_credits_x10`、Webhook(→rcWebhook関数URL)設定
- [ ] **App Store Connect**: アプリ登録、サブスク2種+消耗型1種の登録、3日無料トライアル設定、
      Small Business Program 申請

## 4. Functionsのシークレット・パラメータ設定とデプロイ

- [x] **代行実施済み**: `DEVICE_ID_PEPPER`(外部サービス不要のランダム内部秘密値)を生成し
      Secret Managerへ登録済み(RYO承認済み。値はSecret Manager内のみで表示・保存していない)
- [ ] **未了(Cloud Runサービス確認 = Functions 0件デプロイ)**: 残りのシークレット4件は
      Meta/X/RevenueCatのキー取得後でないと値を投入できない:

```sh
cd /Users/r/Source/ryo_nn/functions && pnpm install && pnpm run build && cd ..
# シークレット(それぞれ値を投入。DEVICE_ID_PEPPERは登録済みのため対象外)
firebase functions:secrets:set IG_APP_SECRET --project flutter-camera-ryonn
firebase functions:secrets:set X_CLIENT_SECRET --project flutter-camera-ryonn
firebase functions:secrets:set RC_WEBHOOK_AUTH --project flutter-camera-ryonn
firebase functions:secrets:set RC_SECRET_API_KEY --project flutter-camera-ryonn
# デプロイ(パラメータ IG_APP_ID / X_CLIENT_ID / RC_EXPECTED_ENVIRONMENT は初回デプロイ時に対話入力。
# KMS_KEY_NAME は下記の値を入力:
#   projects/flutter-camera-ryonn/locations/asia-northeast1/keyRings/sns-tokens/cryptoKeys/token-key
firebase deploy --only functions --project flutter-camera-ryonn
```

## 5. クライアントのビルド時値・OAuthスキーム

- [ ] リリースビルドの `--dart-define` を確定:
      `RC_APPLE_API_KEY` / `RC_GOOGLE_API_KEY`(RevenueCat)、
      `IG_OAUTH_CLIENT_ID` / `IG_OAUTH_REDIRECT_URI` / `X_OAUTH_CLIENT_ID` / `X_OAUTH_REDIRECT_URI`
- [x] OAuthリダイレクトURLスキームのネイティブ登録は**実施済み**(スキーム: `tokyo.n-n.fluttercamera`。
      iOS: Info.plist CFBundleURLTypes / Android: build.gradle.kts appAuthRedirectScheme)
- [ ] Meta/X側のアプリ設定にリダイレクトURIを登録し、同じ値を `--dart-define` の
      `IG_OAUTH_REDIRECT_URI` / `X_OAUTH_REDIRECT_URI` に指定
      (例: `tokyo.n-n.fluttercamera://oauth/callback`)

## 6. 法定表記・運営データ

- [ ] `docs/legal/` のドラフト3種(利用規約・プライバシーポリシー・特商法表記)の【要記入】を埋めて確定
      (必要に応じ専門家レビュー)→ Webへホスティング
- [ ] URLを Firestore `appConfig/billing` に投入(ペイウォールに自動表示される):
      フィールド `termsUrl` / `privacyUrl` / `tokushoUrl`
- [x] アプリアイコンは**暫定適用済み**(A案「シャッター×スパーク」、iOS/Android両対応。
      差し替えは `docs/brand/icon-proposals/` の画像を変更して `dart run flutter_launcher_icons` を再実行)
- [ ] アイコンの最終決定(A/B/C案または新規制作)、スプラッシュ画像、
      プリセット用フレーム/スタンプ素材の制作・`assets` への投入

## 7. リリース前提の実測検証(要件§9)

- [ ] X従量課金の単価実測: (a)画像付き投稿に$0.015が適用されるか (b)動画付き投稿の単価
      (c)MOV(QuickTime)動画の受理可否 (d)URL付き$0.200の判定仕様
      → 結果に応じてプラン枠(30/150回)と価格を最終確定
- [ ] X動画の解像度制限(公式記載1280x1024)の実効性確認(アプリ録画は720pで回避済み)

## 8. 手動結合テスト(RYO実施。証跡は `証跡/` フォルダへ)

- [ ] サインアップ→ログイン→SMS電話番号認証
- [ ] 撮影(写真/動画)・ライブラリ取り込み・パターン適用・微調整
- [ ] Instagram連携(プロアカウント判定・切替ガイド)・X連携
- [ ] 投稿(画像/動画×IG/X、URLブロック、残回数表示、無料枠のデバイス制御)
- [ ] 課金サンドボックス(購入・トライアル・リストア・クレジット消費・Webhook反映)
- [ ] アカウント削除(データ消去の確認)
- [ ] Meta App Review 通過確認 → **リリース判定**
