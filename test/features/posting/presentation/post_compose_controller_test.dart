import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_camera/src/features/posting/data/functions_post_repository.dart';
import 'package:flutter_camera/src/features/posting/data/storage_upload_service.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_camera/src/features/posting/domain/post_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_camera/src/features/posting/domain/storage_upload_service.dart';
import 'package:flutter_camera/src/features/posting/presentation/post_compose_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPostRepository extends Mock implements PostRepository {}

class _MockStorageUploadService extends Mock implements StorageUploadService {}

void main() {
  late _MockPostRepository postRepository;
  late _MockStorageUploadService uploadService;
  late ProviderContainer container;

  setUp(() {
    postRepository = _MockPostRepository();
    uploadService = _MockStorageUploadService();
    // patterns機能(selectedPatternProvider)は未実装のためoverrideしていない。
    // design.mdのプロバイダー表で `selectedPatternProvider` の「主な依存」列は
    // "-"(依存なし)とされており、実装後も初期値は「未選択(null)」であることを
    // 前提としたテストとする(notes参照)。
    container = ProviderContainer.test(
      overrides: [
        postRepositoryProvider.overrideWithValue(postRepository),
        storageUploadServiceProvider.overrideWithValue(uploadService),
      ],
    );
    // autoDispose(既定)のControllerがテスト中に破棄されないよう、
    // 明示的なリスナーで購読を維持する(riverpodテストの定石)。
    container.listen(postComposeControllerProvider, (_, _) {});
  });

  test('画像アップロード→投稿呼び出しが成功した場合、stateにpostIdが入る', () async {
    when(() => postRepository.generatePostId()).thenReturn('post-1');
    when(
      () => uploadService.uploadPostImage(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
      ),
    ).thenAnswer((_) async => 'users/uid1/postImages/img1.jpg');
    when(
      () => postRepository.publishPost(
        postId: any(named: 'postId'),
        imagePath: any(named: 'imagePath'),
        caption: any(named: 'caption'),
        instagram: any(named: 'instagram'),
        x: any(named: 'x'),
        patternId: any(named: 'patternId'),
        force: any(named: 'force'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        mediaType: any(named: 'mediaType'),
        durationSec: any(named: 'durationSec'),
        fileSizeBytes: any(named: 'fileSizeBytes'),
      ),
    ).thenAnswer(
      (_) async => const PublishPostOutcome(
        postId: 'post-1',
        overallStatus: PostOverallStatus.processing,
      ),
    );

    await container
        .read(postComposeControllerProvider.notifier)
        .submit(
          uid: 'uid1',
          media: const PostMedia.image(
            EditedImage(filePath: '/tmp/a.jpg', isFinal: true),
          ),
          caption: 'hello',
          instagram: true,
          x: false,
        );

    final state = container.read(postComposeControllerProvider);
    expect(state.value, 'post-1');
    verify(
      () => uploadService.uploadPostImage(
        uid: 'uid1',
        localFilePath: '/tmp/a.jpg',
      ),
    ).called(1);
    verifyNever(
      () => uploadService.uploadPostVideo(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
        contentType: any(named: 'contentType'),
      ),
    );
    verify(
      () => postRepository.publishPost(
        postId: 'post-1',
        imagePath: 'users/uid1/postImages/img1.jpg',
        caption: 'hello',
        instagram: true,
        x: false,
        patternId: null,
        force: false,
        deviceId: null,
        platform: null,
        mediaType: 'image',
        durationSec: null,
        fileSizeBytes: null,
      ),
    ).called(1);
  });

  test('動画アップロード→投稿呼び出しが成功した場合、mediaType/長さ/サイズが渡される', () async {
    when(() => postRepository.generatePostId()).thenReturn('post-video-1');
    when(
      () => uploadService.uploadPostVideo(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => 'users/uid1/postImages/video1.mp4');
    when(
      () => postRepository.publishPost(
        postId: any(named: 'postId'),
        imagePath: any(named: 'imagePath'),
        caption: any(named: 'caption'),
        instagram: any(named: 'instagram'),
        x: any(named: 'x'),
        patternId: any(named: 'patternId'),
        force: any(named: 'force'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        mediaType: any(named: 'mediaType'),
        durationSec: any(named: 'durationSec'),
        fileSizeBytes: any(named: 'fileSizeBytes'),
      ),
    ).thenAnswer(
      (_) async => const PublishPostOutcome(
        postId: 'post-video-1',
        overallStatus: PostOverallStatus.processing,
      ),
    );

    await container
        .read(postComposeControllerProvider.notifier)
        .submit(
          uid: 'uid1',
          media: const PostMedia.video(
            filePath: '/tmp/a.mp4',
            durationSec: 12.5,
            fileSizeBytes: 2048,
            contentType: 'video/mp4',
          ),
          caption: 'hello video',
          instagram: false,
          x: true,
        );

    final state = container.read(postComposeControllerProvider);
    expect(state.value, 'post-video-1');
    verify(
      () => uploadService.uploadPostVideo(
        uid: 'uid1',
        localFilePath: '/tmp/a.mp4',
        contentType: 'video/mp4',
      ),
    ).called(1);
    verifyNever(
      () => uploadService.uploadPostImage(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
      ),
    );
    verify(
      () => postRepository.publishPost(
        postId: 'post-video-1',
        imagePath: 'users/uid1/postImages/video1.mp4',
        caption: 'hello video',
        instagram: false,
        x: true,
        patternId: null,
        force: false,
        deviceId: null,
        platform: null,
        mediaType: 'video',
        durationSec: 12.5,
        fileSizeBytes: 2048,
      ),
    ).called(1);
  });

  test('画像アップロードが失敗した場合、AsyncErrorになりFunctionsは呼び出さない', () async {
    when(() => postRepository.generatePostId()).thenReturn('post-2');
    when(
      () => uploadService.uploadPostImage(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
      ),
    ).thenThrow(const StorageException('アップロードに失敗しました'));

    await container
        .read(postComposeControllerProvider.notifier)
        .submit(
          uid: 'uid1',
          media: const PostMedia.image(
            EditedImage(filePath: '/tmp/a.jpg', isFinal: true),
          ),
          caption: '',
          instagram: true,
          x: false,
        );

    final state = container.read(postComposeControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<StorageException>());
    verifyNever(
      () => postRepository.publishPost(
        postId: any(named: 'postId'),
        imagePath: any(named: 'imagePath'),
        caption: any(named: 'caption'),
        instagram: any(named: 'instagram'),
        x: any(named: 'x'),
        mediaType: any(named: 'mediaType'),
      ),
    );
  });

  test('Functions呼び出しが失敗した場合、AsyncErrorになる', () async {
    when(() => postRepository.generatePostId()).thenReturn('post-3');
    when(
      () => uploadService.uploadPostImage(
        uid: any(named: 'uid'),
        localFilePath: any(named: 'localFilePath'),
      ),
    ).thenAnswer((_) async => 'users/uid1/postImages/img3.jpg');
    when(
      () => postRepository.publishPost(
        postId: any(named: 'postId'),
        imagePath: any(named: 'imagePath'),
        caption: any(named: 'caption'),
        instagram: any(named: 'instagram'),
        x: any(named: 'x'),
        patternId: any(named: 'patternId'),
        force: any(named: 'force'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        mediaType: any(named: 'mediaType'),
        durationSec: any(named: 'durationSec'),
        fileSizeBytes: any(named: 'fileSizeBytes'),
      ),
    ).thenThrow(
      const SnsPostException(
        '上限到達',
        provider: _dummyProvider,
        apiErrorCode: 'x_quota_exceeded',
      ),
    );

    await container
        .read(postComposeControllerProvider.notifier)
        .submit(
          uid: 'uid1',
          media: const PostMedia.image(
            EditedImage(filePath: '/tmp/a.jpg', isFinal: true),
          ),
          caption: '',
          instagram: false,
          x: true,
        );

    final state = container.read(postComposeControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<SnsPostException>());
  });
}

// SnsPostException.provider はテスト対象外のためダミー値を使う。
const _dummyProvider = SnsProvider.x;
