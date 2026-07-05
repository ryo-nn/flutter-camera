import 'package:camera/camera.dart';
import 'package:flutter_camera/src/core/camera/available_cameras_provider.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/camera/data/camera_service.dart';
import 'package:flutter_camera/src/features/camera/domain/camera_capture_mode.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_session.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// NOTE: `availableCamerasProvider` は core 側追加待ちのプロバイダー(coreChangeRequests参照)。
// core側実装が揃うまで本テストはコンパイルできない(並列実装中のため、design.mdの規約通り)。

class MockCameraService extends Mock implements CameraService {}

class MockCameraController extends Mock implements CameraController {}

class _FakeCameraController extends Fake implements CameraController {}

const _front = CameraDescription(
  name: 'front',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 0,
);
const _back = CameraDescription(
  name: 'back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

void main() {
  late MockCameraService cameraService;
  late MockCameraController controller;

  setUpAll(() {
    // `any()` マッチャー(verifyNever(() => cameraService.initialize(any())))が
    // 内部でダミー値を要求するため登録する(mocktailの規約)。
    registerFallbackValue(_front);
    registerFallbackValue(_FakeCameraController());
  });

  setUp(() {
    cameraService = MockCameraService();
    controller = MockCameraController();
    // テスト終了時のcontainer.dispose()でCameraSessionのonDisposeが
    // controller保持中のservice.dispose()を呼ぶため、既定で成功させておく
    // (個別テストでverify対象にする場合はこの後で上書きされる)。
    when(() => cameraService.dispose(any())).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer({
    List<CameraDescription> cameras = const [_front, _back],
  }) {
    final container = ProviderContainer(
      overrides: [
        availableCamerasProvider.overrideWith((ref) async => cameras),
        cameraServiceProvider.overrideWithValue(cameraService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CameraSession.build (design.md §1.2/§1.3準拠)', () {
    test('フロントカメラを優先して初期化し ready を返す', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);

      final container = makeContainer();
      final result = await container.read(cameraSessionProvider.future);

      expect(result, isA<CameraSessionReady>());
      expect((result as CameraSessionReady).lens, CameraLensDirection.front);
      verify(() => cameraService.initialize(_front)).called(1);
    });

    test('フロントカメラが無ければ先頭のカメラで初期化する', () async {
      when(
        () => cameraService.initialize(_back),
      ).thenAnswer((_) async => controller);

      final container = makeContainer(cameras: const [_back]);
      final result = await container.read(cameraSessionProvider.future);

      expect(result, isA<CameraSessionReady>());
      expect((result as CameraSessionReady).lens, CameraLensDirection.back);
    });

    test('カメラが1台も無い場合はエラー状態を返す(クラッシュガード)', () async {
      final container = makeContainer(cameras: const []);
      final result = await container.read(cameraSessionProvider.future);

      expect(result, const CameraSessionState.error('no_camera_available'));
      verifyNever(() => cameraService.initialize(any()));
    });

    test('CameraAccessDenied は再試行可能なpermissionDeniedへ変換される', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenThrow(CameraException('CameraAccessDenied', 'denied'));

      final container = makeContainer();
      final result = await container.read(cameraSessionProvider.future);

      expect(result, const CameraSessionState.permissionDenied(canRetry: true));
    });

    test(
      'CameraAccessDeniedWithoutPrompt は再試行不可のpermissionDeniedへ変換される',
      () async {
        when(() => cameraService.initialize(_front)).thenThrow(
          CameraException('CameraAccessDeniedWithoutPrompt', 'denied'),
        );

        final container = makeContainer();
        final result = await container.read(cameraSessionProvider.future);

        expect(
          result,
          const CameraSessionState.permissionDenied(canRetry: false),
        );
      },
    );

    test('CameraAccessRestricted は restricted へ変換される', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenThrow(CameraException('CameraAccessRestricted', 'restricted'));

      final container = makeContainer();
      final result = await container.read(cameraSessionProvider.future);

      expect(result, const CameraSessionState.restricted());
    });

    test('未分類のCameraExceptionはerror(code)へ変換される', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenThrow(CameraException('cameraNotReadable', 'busy'));

      final container = makeContainer();
      final result = await container.read(cameraSessionProvider.future);

      expect(result, const CameraSessionState.error('cameraNotReadable'));
    });
  });

  group('CameraSession.switchCamera (design.md §1.3準拠)', () {
    test('setDescriptionが成功した場合はcontrollerを維持したまま切替える', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.setDescription(controller, _back),
      ).thenAnswer((_) async {});

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container.read(cameraSessionProvider.notifier).switchCamera();

      final state = container.read(cameraSessionProvider).value;
      expect(state, isA<CameraSessionReady>());
      final ready = state as CameraSessionReady;
      expect(ready.lens, CameraLensDirection.back);
      expect(ready.controller, same(controller));
      verify(() => cameraService.setDescription(controller, _back)).called(1);
    });

    test('setDescriptionが失敗した場合はdispose後に再生成する', () async {
      final backController = MockCameraController();
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.setDescription(controller, _back),
      ).thenThrow(CameraException('setFailed', 'busy'));
      when(() => cameraService.dispose(controller)).thenAnswer((_) async {});
      when(
        () => cameraService.initialize(_back),
      ).thenAnswer((_) async => backController);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container.read(cameraSessionProvider.notifier).switchCamera();

      final state = container.read(cameraSessionProvider).value;
      expect(state, isA<CameraSessionReady>());
      expect((state as CameraSessionReady).controller, same(backController));
      verify(() => cameraService.dispose(controller)).called(1);
      verify(() => cameraService.initialize(_back)).called(1);
    });
  });

  group('CameraSession.suspend / resume (design.md §1.4準拠)', () {
    test('suspendはcontrollerを破棄しsuspended状態にする', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(() => cameraService.dispose(controller)).thenAnswer((_) async {});

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container.read(cameraSessionProvider.notifier).suspend();

      expect(
        container.read(cameraSessionProvider).value,
        const CameraSessionState.suspended(),
      );
      verify(() => cameraService.dispose(controller)).called(1);
    });

    test('resumeは直前のlensDirectionで再初期化する', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(() => cameraService.dispose(controller)).thenAnswer((_) async {});

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);
      await container.read(cameraSessionProvider.notifier).suspend();

      await container.read(cameraSessionProvider.notifier).resume();

      final state = container.read(cameraSessionProvider).value;
      expect(state, isA<CameraSessionReady>());
      expect((state as CameraSessionReady).lens, CameraLensDirection.front);
      verify(() => cameraService.initialize(_front)).called(2);
    });

    test('controllerが生存中はresumeを呼んでも再初期化しない', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container.read(cameraSessionProvider.notifier).resume();

      verify(() => cameraService.initialize(_front)).called(1);
    });
  });

  group('CameraSession.capture (design.md §1.3準拠)', () {
    test('takePictureの結果をそのまま返す', () async {
      final xFile = XFile('tmp/photo.jpg');
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.takePicture(controller),
      ).thenAnswer((_) async => xFile);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      final result = await container
          .read(cameraSessionProvider.notifier)
          .capture();

      expect(result.path, 'tmp/photo.jpg');
    });

    test('CameraExceptionはCameraAccessExceptionに変換してthrowする', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.takePicture(controller),
      ).thenThrow(CameraException('captureFailed', 'disk full'));

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      expect(
        () => container.read(cameraSessionProvider.notifier).capture(),
        throwsA(isA<CameraAccessException>()),
      );
    });

    test('コントローラ未初期化状態ではCameraAccessExceptionをthrowする', () async {
      final container = makeContainer(cameras: const []);
      await container.read(cameraSessionProvider.future); // error状態

      expect(
        () => container.read(cameraSessionProvider.notifier).capture(),
        throwsA(isA<CameraAccessException>()),
      );
    });
  });

  group('CameraSession.switchMode (design.md追補: S-04モード切替トグル)', () {
    test('写真→動画切替: dispose後にinitializeForVideoで再初期化する', () async {
      final videoController = MockCameraController();
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.initializeForVideo(_front),
      ).thenAnswer((_) async => videoController);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container
          .read(cameraSessionProvider.notifier)
          .switchMode(CameraCaptureMode.video);

      final state = container.read(cameraSessionProvider).value;
      expect(state, isA<CameraSessionReady>());
      final ready = state as CameraSessionReady;
      expect(ready.mode, CameraCaptureMode.video);
      expect(ready.controller, same(videoController));
      expect(ready.lens, CameraLensDirection.front); // レンズ向きは維持する
      verify(() => cameraService.dispose(controller)).called(1);
      verify(() => cameraService.initializeForVideo(_front)).called(1);
    });

    test('同一モードへの切替は何もしない', () async {
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);

      await container
          .read(cameraSessionProvider.notifier)
          .switchMode(CameraCaptureMode.photo);

      verifyNever(() => cameraService.dispose(any()));
      verifyNever(() => cameraService.initializeForVideo(any()));
    });

    test('動画→写真切替: dispose後にinitializeで再初期化する', () async {
      final videoController = MockCameraController();
      final photoController2 = MockCameraController();
      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => controller);
      when(
        () => cameraService.initializeForVideo(_front),
      ).thenAnswer((_) async => videoController);

      final container = makeContainer();
      await container.read(cameraSessionProvider.future);
      await container
          .read(cameraSessionProvider.notifier)
          .switchMode(CameraCaptureMode.video);

      when(
        () => cameraService.initialize(_front),
      ).thenAnswer((_) async => photoController2);

      await container
          .read(cameraSessionProvider.notifier)
          .switchMode(CameraCaptureMode.photo);

      final state = container.read(cameraSessionProvider).value;
      expect(state, isA<CameraSessionReady>());
      final ready = state as CameraSessionReady;
      expect(ready.mode, CameraCaptureMode.photo);
      expect(ready.controller, same(photoController2));
      verify(() => cameraService.dispose(videoController)).called(1);
    });
  });

  group(
    'CameraSession.startRecording / stopRecording (design.md追補: S-04動画撮影モード)',
    () {
      test('startRecordingはCameraServiceへ委譲する', () async {
        when(
          () => cameraService.initialize(_front),
        ).thenAnswer((_) async => controller);
        when(
          () => cameraService.startVideoRecording(controller),
        ).thenAnswer((_) async {});

        final container = makeContainer();
        await container.read(cameraSessionProvider.future);

        await container.read(cameraSessionProvider.notifier).startRecording();

        verify(() => cameraService.startVideoRecording(controller)).called(1);
      });

      test('stopRecordingはCameraServiceの返す動画ファイルをそのまま返す', () async {
        final xFile = XFile('tmp/video.mp4');
        when(
          () => cameraService.initialize(_front),
        ).thenAnswer((_) async => controller);
        when(
          () => cameraService.stopVideoRecording(controller),
        ).thenAnswer((_) async => xFile);

        final container = makeContainer();
        await container.read(cameraSessionProvider.future);

        final result = await container
            .read(cameraSessionProvider.notifier)
            .stopRecording();

        expect(result.path, 'tmp/video.mp4');
      });

      test('startRecordingでCameraExceptionはCameraAccessExceptionに変換される', () async {
        when(
          () => cameraService.initialize(_front),
        ).thenAnswer((_) async => controller);
        when(
          () => cameraService.startVideoRecording(controller),
        ).thenThrow(CameraException('recordingFailed', 'disk full'));

        final container = makeContainer();
        await container.read(cameraSessionProvider.future);

        expect(
          () => container.read(cameraSessionProvider.notifier).startRecording(),
          throwsA(isA<CameraAccessException>()),
        );
      });

      test('コントローラ未初期化状態ではCameraAccessExceptionをthrowする', () async {
        final container = makeContainer(cameras: const []);
        await container.read(cameraSessionProvider.future); // error状態

        expect(
          () => container.read(cameraSessionProvider.notifier).startRecording(),
          throwsA(isA<CameraAccessException>()),
        );
        expect(
          () => container.read(cameraSessionProvider.notifier).stopRecording(),
          throwsA(isA<CameraAccessException>()),
        );
      });
    },
  );
}
