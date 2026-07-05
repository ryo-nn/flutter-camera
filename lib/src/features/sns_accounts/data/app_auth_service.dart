import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_auth_service.g.dart';

/// [AppAuthService] の `flutter_appauth` 実装
/// (backend章「認可フロー」節: `flutter_appauth.authorize()` でトークン交換を
/// 行わずに認可コード+PKCE検証子のみを取得する)。
///
/// クライアントID・リダイレクトURIは秘匿情報ではないが、Meta/X の開発者コンソールへの
/// 実アプリ登録値(かつ AndroidManifest.xml / Info.plist 側のURLスキーム登録と一致させる
/// 必要がある値)であり、本featureのスコープ外の値をコードへハードコードしないため
/// `--dart-define` 経由の注入(`String.fromEnvironment`)とする
/// (coreChangeRequests参照: プラットフォーム設定側でのURLスキーム登録+
/// ビルド時の値注入が必要)。
class FlutterAppAuthService implements AppAuthService {
  const FlutterAppAuthService(this._appAuth);

  final FlutterAppAuth _appAuth;

  static const _igClientId = String.fromEnvironment('IG_OAUTH_CLIENT_ID');
  static const _igRedirectUri = String.fromEnvironment('IG_OAUTH_REDIRECT_URI');
  static const _xClientId = String.fromEnvironment('X_OAUTH_CLIENT_ID');
  static const _xRedirectUri = String.fromEnvironment('X_OAUTH_REDIRECT_URI');

  @override
  Future<SnsAuthorizationResult> authorizeInstagram() {
    return _authorize(
      clientId: _igClientId,
      redirectUri: _igRedirectUri,
      // backend章「認可フロー」節の該当エンドポイント。
      authorizationEndpoint: 'https://www.instagram.com/oauth/authorize',
      // Business LoginにPKCEの規定はなくクライアントからはtokenEndpointを呼ばないが、
      // AuthorizationServiceConfigurationの必須フィールドのため設定する
      // (backend章「認可フロー」節の短期トークン取得エンドポイント)。
      tokenEndpoint: 'https://api.instagram.com/oauth/access_token',
      scopes: const [
        'instagram_business_basic',
        'instagram_business_content_publish',
      ],
    );
  }

  @override
  Future<SnsAuthorizationResult> authorizeX() {
    return _authorize(
      clientId: _xClientId,
      redirectUri: _xRedirectUri,
      authorizationEndpoint: 'https://x.com/i/oauth2/authorize',
      tokenEndpoint: 'https://api.x.com/2/oauth2/token',
      // backend章「X連携設計」節: POST /2/tweets必須スコープ(tweet.read/tweet.write/
      // users.read)+media.write+offline.access(リフレッシュトークン取得用)。
      scopes: const [
        'tweet.read',
        'tweet.write',
        'users.read',
        'media.write',
        'offline.access',
      ],
    );
  }

  Future<SnsAuthorizationResult> _authorize({
    required String clientId,
    required String redirectUri,
    required String authorizationEndpoint,
    required String tokenEndpoint,
    required List<String> scopes,
  }) async {
    try {
      final response = await _appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: scopes,
        ),
      );
      final code = response.authorizationCode;
      if (code == null) {
        // 公式には正常応答時は必ず非null(pub.dev APIリファレンスで確認済み)だが、
        // 防御的にキャンセル扱いへフォールバックする。
        throw const SnsAuthorizationCancelledException();
      }
      return SnsAuthorizationResult(
        authorizationCode: code,
        codeVerifier: response.codeVerifier,
        redirectUri: redirectUri,
      );
    } on FlutterAppAuthUserCancelledException {
      // pub.dev flutter_appauth 公式READMEで確認済みの例外クラス。
      throw const SnsAuthorizationCancelledException();
    }
    // FlutterAppAuthPlatformException 等はそのまま呼び出し元(SnsConnectController)へ
    // 伝播させ、data層のリポジトリ実装(functions_sns_account_repository.dart)側の
    // 責務である「Firestore/Functions関連のSDK例外→AppException変換」とは別に、
    // controller側で SnsAuthException へ変換する(コネクタごとの provider を
    // 知っているのはcontrollerのため)。
  }
}

/// flutter_appauthラッパのDI(design.md アーキテクチャ章 `appAuthServiceProvider`)。
@Riverpod(keepAlive: true)
AppAuthService appAuthService(Ref ref) {
  return const FlutterAppAuthService(FlutterAppAuth());
}
