// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_id_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceIdService)
final deviceIdServiceProvider = DeviceIdServiceProvider._();

final class DeviceIdServiceProvider
    extends
        $FunctionalProvider<DeviceIdService, DeviceIdService, DeviceIdService>
    with $Provider<DeviceIdService> {
  DeviceIdServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdServiceHash();

  @$internal
  @override
  $ProviderElement<DeviceIdService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceIdService create(Ref ref) {
    return deviceIdService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdService>(value),
    );
  }
}

String _$deviceIdServiceHash() => r'857c5561a7deb745d0712796f85f4a658f33efc9';
