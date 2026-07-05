// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// カメラ撮影のライフサイクル管理(design.md カメラ・自動加工パイプライン設計 §1準拠)。
///
/// `CameraController` は本Notifierが単独所有し、widget側で直接生成・破棄しない
/// (design.md §1.3準拠)。autoDispose のため、S-04(`CameraScreen`)がpopされ
/// 誰も watch しなくなった時点で `ref.onDispose` が走りコントローラを解放する。

@ProviderFor(CameraSession)
final cameraSessionProvider = CameraSessionProvider._();

/// カメラ撮影のライフサイクル管理(design.md カメラ・自動加工パイプライン設計 §1準拠)。
///
/// `CameraController` は本Notifierが単独所有し、widget側で直接生成・破棄しない
/// (design.md §1.3準拠)。autoDispose のため、S-04(`CameraScreen`)がpopされ
/// 誰も watch しなくなった時点で `ref.onDispose` が走りコントローラを解放する。
final class CameraSessionProvider
    extends $AsyncNotifierProvider<CameraSession, CameraSessionState> {
  /// カメラ撮影のライフサイクル管理(design.md カメラ・自動加工パイプライン設計 §1準拠)。
  ///
  /// `CameraController` は本Notifierが単独所有し、widget側で直接生成・破棄しない
  /// (design.md §1.3準拠)。autoDispose のため、S-04(`CameraScreen`)がpopされ
  /// 誰も watch しなくなった時点で `ref.onDispose` が走りコントローラを解放する。
  CameraSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraSessionHash();

  @$internal
  @override
  CameraSession create() => CameraSession();
}

String _$cameraSessionHash() => r'3abc7282b8042b653a463941b4880cf6d90ff339';

/// カメラ撮影のライフサイクル管理(design.md カメラ・自動加工パイプライン設計 §1準拠)。
///
/// `CameraController` は本Notifierが単独所有し、widget側で直接生成・破棄しない
/// (design.md §1.3準拠)。autoDispose のため、S-04(`CameraScreen`)がpopされ
/// 誰も watch しなくなった時点で `ref.onDispose` が走りコントローラを解放する。

abstract class _$CameraSession extends $AsyncNotifier<CameraSessionState> {
  FutureOr<CameraSessionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CameraSessionState>, CameraSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CameraSessionState>, CameraSessionState>,
              AsyncValue<CameraSessionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
