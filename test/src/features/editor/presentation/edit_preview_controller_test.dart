// NOTE(統合フェーズ申し送り): riverpod_generator によるコード生成
// (edit_preview_controller.g.dart 等)は統合フェーズで一括実行する方針のため、
// 現時点では未生成(`build_runner build` 実行後に実行可能になる)。
import 'dart:io';

import 'package:camera/camera.dart' show CameraLensDirection;
import 'package:flutter/services.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_camera/src/features/editor/data/pro_image_editor_apply_service.dart';
import 'package:flutter_camera/src/features/editor/domain/pattern_apply_service.dart';
import 'package:flutter_camera/src/features/editor/presentation/edit_preview_controller.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// `EditPreviewController.confirm`/`onAdjustEditingComplete`はdesign.md
// §3.1準拠で`path_provider`の`getTemporaryDirectory()`を直接呼び出すため、
// ネイティブ側の実装を持たないテスト環境ではmethod channelをモックする。
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

class _MockPatternApplyService extends Mock implements PatternApplyService {}

void main() {
  late _MockPatternApplyService service;
  late ProviderContainer container;
  late CapturedPhoto capturedPhoto;
  late Directory tempDir;

  const normalized = NormalizedImage(
    filePath: '/tmp/capture_normalized.png',
    width: 1080,
    height: 1350,
  );

  final pattern = Pattern(
    id: 'p1',
    ownerType: PatternOwnerType.user,
    ownerUid: 'uid1',
    name: 'ナチュラル',
    filterParams: const FilterParams(
      brightness: 0.1,
      contrast: 0,
      saturation: 0,
      exposure: 0,
      hue: 0,
      temperature: 0,
      tint: 0,
      fade: 0,
      smoothing: 0,
    ),
    frameAssetId: null,
    stampLayers: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(pattern);
  });

  setUp(() async {
    service = _MockPatternApplyService();
    tempDir = await Directory.systemTemp.createTemp('edit_preview_test_');
    capturedPhoto = CapturedPhoto(
      imagePath: '/tmp/capture_raw.jpg',
      lensDirection: CameraLensDirection.front,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        });

    when(
      () => service.normalizeCapture(any()),
    ).thenAnswer((_) async => normalized);
    when(() => service.precachePatternAssets(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [patternApplyServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'buildはnormalizeCaptureとprecachePatternAssetsを呼び、isFinal=falseを返す',
    () async {
      final providerInstance = editPreviewControllerProvider(capturedPhoto);

      final result = await container.read(providerInstance.future);

      expect(result.filePath, normalized.filePath);
      expect(result.isFinal, isFalse);
      verify(() => service.normalizeCapture(capturedPhoto.imagePath)).called(1);
      verify(() => service.precachePatternAssets(any())).called(1);
    },
  );

  test('reapplyPatternは新しいパターンのアセットをprecacheし、isFinal=falseのまま維持する', () async {
    final providerInstance = editPreviewControllerProvider(capturedPhoto);
    await container.read(providerInstance.future);

    final notifier = container.read(providerInstance.notifier);
    await notifier.reapplyPattern(pattern);

    final state = container.read(providerInstance);
    expect(state.value?.filePath, normalized.filePath);
    expect(state.value?.isFinal, isFalse);
    verify(() => service.precachePatternAssets(pattern)).called(1);
  });

  test('confirmはfinalizeJpegの結果を一時JPEGに保存しisFinal=trueで返す', () async {
    final jpegBytes = Uint8List.fromList([1, 2, 3, 4]);
    when(
      () => service.finalizeJpeg(
        normalizedImagePath: any(named: 'normalizedImagePath'),
        pattern: any(named: 'pattern'),
        imageWidth: any(named: 'imageWidth'),
        imageHeight: any(named: 'imageHeight'),
        confirmedCandidateJpeg: any(named: 'confirmedCandidateJpeg'),
      ),
    ).thenAnswer((_) async => jpegBytes);

    final providerInstance = editPreviewControllerProvider(capturedPhoto);
    // 実アプリではS-05(EditPreviewScreen)がref.watchし続けるため、
    // autoDisposeプロバイダーがconfirm()の非同期処理中に破棄されない。
    // テストでも同じ前提を再現するためlistenでライフサイクルを維持する。
    container.listen(providerInstance, (_, _) {});
    await container.read(providerInstance.future);

    final notifier = container.read(providerInstance.notifier);
    final result = await notifier.confirm(pattern);

    expect(result.isFinal, isTrue);
    final savedBytes = await File(result.filePath).readAsBytes();
    expect(savedBytes, jpegBytes);

    verify(
      () => service.finalizeJpeg(
        normalizedImagePath: normalized.filePath,
        pattern: pattern,
        imageWidth: normalized.width,
        imageHeight: normalized.height,
        confirmedCandidateJpeg: null,
      ),
    ).called(1);

    await File(result.filePath).delete();
  });
}
