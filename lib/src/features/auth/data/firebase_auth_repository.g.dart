// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 認証リポジトリ実装の DI。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authRepositoryProvider」)

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// 認証リポジトリ実装の DI。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authRepositoryProvider」)

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// 認証リポジトリ実装の DI。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authRepositoryProvider」)
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'dba6c90d4e0f48cd591957bfeb90880a28b1f6d5';

/// 認証状態の購読(ルートガード判定の単一情報源)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authStateChangesProvider」)

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// 認証状態の購読(ルートガード判定の単一情報源)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authStateChangesProvider」)

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// 認証状態の購読(ルートガード判定の単一情報源)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authStateChangesProvider」)
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'09dbb394c77428a6619a365c2a7424038970625f';

/// 現在ログイン中ユーザーにリンク済みの電話番号(S-09「電話番号認証」行の表示用)。
/// 電話番号リンクはFirestoreの `users/{uid}` プロフィールを変更しないため
/// `authStateChangesProvider` では検知できず、リンク完了後は呼び出し側が
/// `ref.invalidate(linkedPhoneNumberProvider)` で明示的に再取得する。

@ProviderFor(linkedPhoneNumber)
final linkedPhoneNumberProvider = LinkedPhoneNumberProvider._();

/// 現在ログイン中ユーザーにリンク済みの電話番号(S-09「電話番号認証」行の表示用)。
/// 電話番号リンクはFirestoreの `users/{uid}` プロフィールを変更しないため
/// `authStateChangesProvider` では検知できず、リンク完了後は呼び出し側が
/// `ref.invalidate(linkedPhoneNumberProvider)` で明示的に再取得する。

final class LinkedPhoneNumberProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// 現在ログイン中ユーザーにリンク済みの電話番号(S-09「電話番号認証」行の表示用)。
  /// 電話番号リンクはFirestoreの `users/{uid}` プロフィールを変更しないため
  /// `authStateChangesProvider` では検知できず、リンク完了後は呼び出し側が
  /// `ref.invalidate(linkedPhoneNumberProvider)` で明示的に再取得する。
  LinkedPhoneNumberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkedPhoneNumberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkedPhoneNumberHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return linkedPhoneNumber(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$linkedPhoneNumberHash() => r'17641ebdcd5677ce61c992fe2ba816fcd813f412';
