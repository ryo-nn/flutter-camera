import 'dart:async';

import 'package:flutter_camera/src/features/posting/data/functions_post_repository.dart';
import 'package:flutter_camera/src/features/posting/data/storage_upload_service.dart';
// patterns featureは未実装だが、design.md「追補による既存章への変更点」節が
// 「postComposeControllerProvider が selectedPatternProvider のIDを
// snsPublishPost へ渡すよう改訂」を明記しているため、design.md記載のパス
// (patterns/presentation/selected_pattern_provider.dart)に従って参照する
// (未存在でよい。統合フェーズで解決される。notes参照)。
import 'package:flutter_camera/src/features/patterns/presentation/selected_pattern_provider.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_compose_controller.g.dart';

/// S-07 一括投稿の実行(アップロード→Functions 呼び出し)を担うController。
/// (design.md アーキテクチャ章 `postComposeControllerProvider` 準拠。
/// state は投稿完了後の `postId`。UIはこれを [postStatusProvider] の
/// familyキーとして渡し、投稿処理モーダルで進捗を購読する)
///
/// design.mdのプロバイダー依存表は `snsConnectionsProvider`(sns_accounts機能)への
/// 依存も挙げているが、接続状態に応じたチェックボックス無効化はUI(画面)側の責務とし、
/// controllerは画面側で検証済みの `instagram`/`x` フラグをそのまま受け取る設計とした
/// (sns_accounts機能のドメイン型に対する詳細フィールド名の推測依存を業務ロジックに
/// 持ち込まないための判断。notes参照)。
@riverpod
class PostComposeController extends _$PostComposeController {
  @override
  FutureOr<String?> build() => null;

  /// 加工済み画像のアップロード → `snsPublishPost` 呼び出しまでを実行する。
  ///
  /// [force] は `posts/{postId}` が既に存在するリトライ呼び出し
  /// (`failureKind: 'unknown'` のターゲットの明示リトライ)でのみ `true` にする
  /// (backend章「リトライ方針」節準拠)。
  ///
  /// [deviceId] / [platform] はfreeプランでXターゲットを選択した場合に
  /// サーバー側が要求する(quota章「デバイス単位の無料枠管理」節)。端末識別子の
  /// 実際の取得(android_id / identifierForVendor)は本featureのスコープ外のため
  /// 呼び出し元から未指定のまま渡されることを許容する(coreChangeRequests参照)。
  ///
  /// 適用パターンのIDは `selectedPatternProvider`(patterns機能・撮影フローで
  /// 選択中のパターン)から解決する(design.md「追補による既存章への変更点」節準拠)。
  ///
  /// [uid] はログイン中ユーザーのUID。呼び出し元(画面)が
  /// `authStateChangesProvider` から解決して渡す(controller自身がauth機能に
  /// 依存すると、mocktailでのユニットテスト時に未実装のauth featureの型
  /// (`AppUser`)を再現する必要が生じテストが脆くなるため、uidは明示引数として
  /// 受け取る設計とした。notes参照)。
  ///
  /// [media] は画像(`PostMedia.image`)/動画(`PostMedia.video`)いずれか
  /// (動画対応追加分)。画像はStorageの `uploadPostImage`、動画は
  /// `uploadPostVideo` を用いてアップロードし、`snsPublishPost` へは
  /// `mediaType`('image' | 'video')と、動画の場合のみ `durationSec` /
  /// `fileSizeBytes` を渡す。
  Future<void> submit({
    required String uid,
    required PostMedia media,
    required String caption,
    required bool instagram,
    required bool x,
    bool force = false,
    String? deviceId,
    String? platform,
  }) async {
    final repository = ref.read(postRepositoryProvider);
    final uploadService = ref.read(storageUploadServiceProvider);
    final patternId = ref.read(selectedPatternProvider)?.id;

    state = const AsyncLoading<String?>();
    state = await AsyncValue.guard(() async {
      final postId = repository.generatePostId();

      final String imagePath;
      final String mediaType;
      double? durationSec;
      int? fileSizeBytes;
      switch (media) {
        case PostMediaImage(:final editedImage):
          imagePath = await uploadService.uploadPostImage(
            uid: uid,
            localFilePath: editedImage.filePath,
          );
          mediaType = 'image';
        case PostMediaVideo(
          filePath: final videoFilePath,
          durationSec: final videoDurationSec,
          fileSizeBytes: final videoFileSizeBytes,
          contentType: final videoContentType,
        ):
          imagePath = await uploadService.uploadPostVideo(
            uid: uid,
            localFilePath: videoFilePath,
            contentType: videoContentType,
          );
          mediaType = 'video';
          durationSec = videoDurationSec;
          fileSizeBytes = videoFileSizeBytes;
      }

      await repository.publishPost(
        postId: postId,
        imagePath: imagePath,
        caption: caption,
        instagram: instagram,
        x: x,
        patternId: patternId,
        force: force,
        deviceId: deviceId,
        platform: platform,
        mediaType: mediaType,
        durationSec: durationSec,
        fileSizeBytes: fileSizeBytes,
      );
      return postId;
    });
  }
}
