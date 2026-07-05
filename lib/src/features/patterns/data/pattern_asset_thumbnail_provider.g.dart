// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_asset_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
/// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
/// + 「Firebase Storage構成」準拠)
///
/// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
/// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
/// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
/// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
/// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。

@ProviderFor(patternAssetDownloadUrl)
final patternAssetDownloadUrlProvider = PatternAssetDownloadUrlFamily._();

/// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
/// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
/// + 「Firebase Storage構成」準拠)
///
/// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
/// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
/// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
/// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
/// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。

final class PatternAssetDownloadUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
  /// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
  /// + 「Firebase Storage構成」準拠)
  ///
  /// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
  /// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
  /// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
  /// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
  /// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。
  PatternAssetDownloadUrlProvider._({
    required PatternAssetDownloadUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patternAssetDownloadUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patternAssetDownloadUrlHash();

  @override
  String toString() {
    return r'patternAssetDownloadUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return patternAssetDownloadUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PatternAssetDownloadUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patternAssetDownloadUrlHash() =>
    r'1f825bdee245dfb873584cb3100c9fb8101e19fb';

/// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
/// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
/// + 「Firebase Storage構成」準拠)
///
/// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
/// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
/// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
/// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
/// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。

final class PatternAssetDownloadUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PatternAssetDownloadUrlFamily._()
    : super(
        retry: null,
        name: r'patternAssetDownloadUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// アセットID(`assets/{assetId}` のドキュメントID)からダウンロードURLを解決する。
  /// (design.md データモデル・ストレージ・セキュリティルール設計章「`assets` コレクション」
  /// + 「Firebase Storage構成」準拠)
  ///
  /// S-06(一覧サムネイル)/ S-06a(フレーム・スタンプ選択タブ)専用。
  /// パターン適用時(S-04/S-05)のローカルキャッシュ済みアセット解決は
  /// editor feature の `AssetCacheService`(design.md カメラ・自動加工パイプライン設計
  /// §4.3)が別途担当するため、本プロバイダーはそれとは独立したサムネイル表示専用の
  /// 軽量経路として実装している(`cached_network_image` 自体のHTTPキャッシュに委ねる)。

  PatternAssetDownloadUrlProvider call(String assetId) =>
      PatternAssetDownloadUrlProvider._(argument: assetId, from: this);

  @override
  String toString() => r'patternAssetDownloadUrlProvider';
}
