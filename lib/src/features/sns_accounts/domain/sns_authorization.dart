/// flutter_appauth ラッパの抽象境界(design.md アプリアーキテクチャ設計
/// 「Riverpod 3.0 プロバイダー設計」`appAuthServiceProvider`
/// # 「flutter_appauthラッパ(認可コード+PKCE取得まで)」準拠)。
///
/// design.md のディレクトリ構造は `app_auth_service.dart` を `data/` にのみ
/// 配置しているが、`AsyncNotifier` コントローラ(`sns_connect_controller.dart`)を
/// mocktail で単体テスト可能にするため、SDK型を含まない本抽象インターフェースを
/// domain層に切り出す(レイヤー責務表「domain: Flutter SDK・Firebase SDKに依存しない
/// 純Dart」に適合。実装は `data/app_auth_service.dart` の `FlutterAppAuthService`)。
abstract interface class AppAuthService {
  /// Instagram(`www.instagram.com/oauth/authorize`)の認可コードを取得する
  /// (backend章「Instagram連携設計」節準拠)。
  Future<SnsAuthorizationResult> authorizeInstagram();

  /// X(`x.com/i/oauth2/authorize`)の認可コード+PKCE検証子を取得する
  /// (backend章「X連携設計」節準拠)。
  Future<SnsAuthorizationResult> authorizeX();
}

/// `flutter_appauth` の `authorize()` が返す `AuthorizationResponse` から
/// 上位層(Cloud Functions呼び出し)に必要な値のみを取り出した値オブジェクト。
class SnsAuthorizationResult {
  const SnsAuthorizationResult({
    required this.authorizationCode,
    required this.codeVerifier,
    required this.redirectUri,
  });

  final String authorizationCode;

  /// X連携は `xExchangeToken` へ渡す必須パラメータ(PKCE検証子)。
  /// Instagramは PKCE の規定がないため `null` になり得る
  /// (backend章「Instagram連携設計」節「注意」参照)。
  final String? codeVerifier;

  /// `authorize()` に渡したものと同一の値(トークン交換時も同じ
  /// `redirect_uri` が要求されるため、認可コード取得に使った値をそのまま運ぶ)。
  final String redirectUri;
}

/// ユーザーが外部認可画面をキャンセルしたことを表すマーカー例外。
///
/// design.md UIフロー章 S-09「状態」列:
/// 「連携キャンセル: SnackBar「連携をキャンセルしました」(エラー扱いにしない)」に
/// 対応するため、`AppException` 階層(core/error/app_exception.dart)には含めない
/// (core/ は変更禁止のため独自に定義。`ErrorMapper`/`listenAppError` の
/// 汎用エラー表示経路を通さず、呼び出し元が個別にcatchして専用文言を出す)。
final class SnsAuthorizationCancelledException implements Exception {
  const SnsAuthorizationCancelledException();
}
