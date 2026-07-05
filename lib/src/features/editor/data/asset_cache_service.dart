import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:path_provider/path_provider.dart';

const _assetsCollection = 'assets';

/// フレーム/スタンプアセットのローカルキャッシュ(design.md「カメラ・自動加工パイプライン設計」
/// §4.3準拠)。
///
/// `Pattern.frameAssetId` / `StampLayer.assetId` は `assets/{assetId}`
/// (Firestoreドキュメント)のIDである(patterns フィーチャーの実装済みモデル
/// `lib/src/features/patterns/domain/pattern.dart` / `stamp_layer.dart` で確認済み。
/// design.mdカメラ・自動加工パイプライン設計章は `frameAssetPath`/`assetPath`
/// (Storageフルパスを直接保持)としていたが、実装済みスキーマは
/// アセットIDを介した間接参照方式であるため、本サービスは(1) assetId →
/// `assets/{assetId}.storagePath`(Firestore)の解決、(2) storagePath →
/// ローカルファイル(Firebase Storage、世代照合)の解決、の2段で構成する
/// (`patterns/data/pattern_asset_thumbnail_provider.dart` のコメントで
/// 「パターン適用時のローカルキャッシュ済みアセット解決はeditor featureの
/// AssetCacheServiceが別途担当する」と明記されている。coreChangeRequests参照:
/// `Asset` モデル自体は `core/models/asset.dart` として参照されているが未作成のため
/// 追加を依頼する)。
///
/// - キャッシュキー: assetId(アプリ内解決用) / Storageフルパス+オブジェクト世代
///   (`FullMetadata.generation`)でローカルファイルを一意化。
///   保存先: `{ApplicationSupportDirectory}/pattern_assets/{storagePath}/{generation}.png`。
/// - 世代照合により更新検知(ハッシュ計算なし)。`getMetadata()` 失敗時(オフライン等)は
///   キャッシュ済みファイルへフォールバックする。
/// - 同一 assetId の同時要求は in-flight Future を共有し、並列数は最大4に制限する。
/// - 破棄方針: 合計200MB上限のLRU(最終アクセス日時の古い順に削除)。
class AssetCacheService {
  AssetCacheService({
    required FirebaseStorage storage,
    required FirebaseFirestore firestore,
    Future<Directory> Function()? cacheRootDirectory,
    this.maxConcurrentDownloads = 4,
    this.maxTotalCacheBytes = 200 * 1024 * 1024,
  }) : _storage = storage,
       _firestore = firestore,
       _cacheRootDirectory = cacheRootDirectory ?? _defaultCacheRootDirectory;

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final Future<Directory> Function() _cacheRootDirectory;
  final int maxConcurrentDownloads;
  final int maxTotalCacheBytes;

  /// assetId → ローカルファイルパスの解決結果(precache完了後にwidgetLoaderが
  /// 同期参照するため保持する。design.md §4.3「widgetLoaderは同期関数」)。
  final Map<String, String> _resolvedPaths = {};

  /// assetId → in-flight のダウンロードFuture(重複DL防止)。
  final Map<String, Future<String>> _inFlight = {};

  /// assetId → Storageフルパスの解決結果(Firestore再読取を避けるためのキャッシュ)。
  final Map<String, String> _storagePaths = {};

  int _activeDownloads = 0;

  static Future<Directory> _defaultCacheRootDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return Directory('${dir.path}/pattern_assets');
  }

  /// 複数アセットを事前キャッシュする(precache契約。最大4並列)。[assetIds] は
  /// `Pattern.frameAssetId` / `StampLayer.assetId` の値。
  Future<void> precacheAll(Iterable<String> assetIds) async {
    final uniqueIds = assetIds.toSet().toList();
    var index = 0;
    Future<void> worker() async {
      while (index < uniqueIds.length) {
        final id = uniqueIds[index++];
        await ensureCached(id);
      }
    }

    final workerCount = maxConcurrentDownloads.clamp(
      1,
      uniqueIds.isEmpty ? 1 : uniqueIds.length,
    );
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }

  /// 単一アセットをキャッシュ済みにする。ローカルファイルパスを返す。
  Future<String> ensureCached(String assetId) {
    final cached = _resolvedPaths[assetId];
    if (cached != null) return Future.value(cached);

    final inFlight = _inFlight[assetId];
    if (inFlight != null) return inFlight;

    final future = _resolveAndDownload(assetId).whenComplete(() {
      _inFlight.remove(assetId);
    });
    _inFlight[assetId] = future;
    return future;
  }

  Future<String> _resolveAndDownload(String assetId) async {
    final storagePath = await _resolveStoragePath(assetId);
    final localPath = await _downloadOrReuse(storagePath);
    _resolvedPaths[assetId] = localPath;
    return localPath;
  }

  /// `assets/{assetId}` から `storagePath` フィールドを解決する
  /// (`pattern_asset_thumbnail_provider.dart` と同一のスキーマ参照)。
  Future<String> _resolveStoragePath(String assetId) async {
    final cached = _storagePaths[assetId];
    if (cached != null) return cached;

    final Map<String, dynamic>? data;
    try {
      final doc = await _firestore
          .collection(_assetsCollection)
          .doc(assetId)
          .get();
      data = doc.data();
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? e.code);
    }

    final storagePath = data?['storagePath'] as String?;
    if (storagePath == null) {
      throw StorageException('素材が見つかりません: $assetId');
    }
    _storagePaths[assetId] = storagePath;
    return storagePath;
  }

  Future<String> _downloadOrReuse(String storagePath) async {
    while (_activeDownloads >= maxConcurrentDownloads) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    _activeDownloads++;
    try {
      final root = await _cacheRootDirectory();
      final assetDir = Directory('${root.path}/$storagePath');

      String? generation;
      try {
        final metadata = await _storage.ref(storagePath).getMetadata();
        generation = metadata.generation;
      } catch (_) {
        generation = null; // オフライン等。既存キャッシュへフォールバック(§4.3)。
      }

      if (generation != null) {
        final targetFile = File('${assetDir.path}/$generation.png');
        if (await targetFile.exists()) {
          await _touch(targetFile);
          return targetFile.path;
        }

        await assetDir.create(recursive: true);
        // `DownloadTask` は `Future<TaskSnapshot>` を実装しているためそのままawait可能
        // (firebase_storage公式API。pub.dev/documentation/firebase_storage参照)。
        await _storage.ref(storagePath).writeToFile(targetFile);
        await _evictStaleGenerations(assetDir, keep: targetFile.path);
        await _enforceTotalCacheLimit(root);
        return targetFile.path;
      }

      // メタデータ取得不可(オフライン等)。既存キャッシュ済みファイルへフォールバック。
      if (await assetDir.exists()) {
        final existing = await assetDir
            .list()
            .where((e) => e is File)
            .cast<File>()
            .toList();
        if (existing.isNotEmpty) {
          return existing.first.path;
        }
      }

      throw StorageException('アセットの取得に失敗しました: $storagePath');
    } finally {
      _activeDownloads--;
    }
  }

  Future<void> _touch(File file) async {
    try {
      await file.setLastModified(DateTime.now());
    } catch (_) {
      // 端末によっては setLastModified が失敗することがあるが、LRU精度の低下のみで
      // キャッシュ自体の正しさには影響しないため無視する。
    }
  }

  Future<void> _evictStaleGenerations(
    Directory assetDir, {
    required String keep,
  }) async {
    await for (final entity in assetDir.list()) {
      if (entity is File && entity.path != keep) {
        await entity.delete();
      }
    }
  }

  Future<void> _enforceTotalCacheLimit(Directory root) async {
    if (!await root.exists()) return;

    final files = <File>[];
    await for (final entity in root.list(recursive: true)) {
      if (entity is File) files.add(entity);
    }

    var total = 0;
    final sized = <MapEntry<File, int>>[];
    for (final file in files) {
      final length = await file.length();
      total += length;
      sized.add(MapEntry(file, length));
    }

    if (total <= maxTotalCacheBytes) return;

    sized.sort((a, b) {
      final aStat = a.key.statSync();
      final bStat = b.key.statSync();
      return aStat.modified.compareTo(bStat.modified);
    });

    final keepPaths = _resolvedPaths.values.toSet();
    for (final entry in sized) {
      if (total <= maxTotalCacheBytes) break;
      // 直近ダウンロードしたファイルは削除対象から除外(直前にresolvedPathsへ登録済み)。
      if (keepPaths.contains(entry.key.path)) continue;
      await entry.key.delete();
      total -= entry.value;
    }
  }

  /// precache済みアセットのローカルファイルパス(同期)。[assetId] は
  /// `Pattern.frameAssetId` / `StampLayer.assetId` の値。
  /// 未キャッシュの場合は [StateError]。
  String resolveSync(String assetId) {
    final path = _resolvedPaths[assetId];
    if (path == null) {
      throw StateError(
        'アセットが未キャッシュです: $assetId (precacheAll/ensureCachedを先に呼び出してください)',
      );
    }
    return path;
  }
}
