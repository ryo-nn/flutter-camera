// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_cameras_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 端末カメラの列挙(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「availableCamerasProvider」準拠。デバイス構成は起動中不変のため keepAlive とする)。
///
/// 関数名を `availableCameras` にすると `camera_plugin.availableCameras()` と
/// 名前衝突するため prefix import が必須(camera feature からの想定利用箇所準拠)。

@ProviderFor(availableCameras)
final availableCamerasProvider = AvailableCamerasProvider._();

/// 端末カメラの列挙(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「availableCamerasProvider」準拠。デバイス構成は起動中不変のため keepAlive とする)。
///
/// 関数名を `availableCameras` にすると `camera_plugin.availableCameras()` と
/// 名前衝突するため prefix import が必須(camera feature からの想定利用箇所準拠)。

final class AvailableCamerasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<camera_plugin.CameraDescription>>,
          List<camera_plugin.CameraDescription>,
          FutureOr<List<camera_plugin.CameraDescription>>
        >
    with
        $FutureModifier<List<camera_plugin.CameraDescription>>,
        $FutureProvider<List<camera_plugin.CameraDescription>> {
  /// 端末カメラの列挙(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
  /// 「availableCamerasProvider」準拠。デバイス構成は起動中不変のため keepAlive とする)。
  ///
  /// 関数名を `availableCameras` にすると `camera_plugin.availableCameras()` と
  /// 名前衝突するため prefix import が必須(camera feature からの想定利用箇所準拠)。
  AvailableCamerasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableCamerasProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableCamerasHash();

  @$internal
  @override
  $FutureProviderElement<List<camera_plugin.CameraDescription>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<camera_plugin.CameraDescription>> create(Ref ref) {
    return availableCameras(ref);
  }
}

String _$availableCamerasHash() => r'bba70265fb81d747159184102cf7c66597a0948d';
