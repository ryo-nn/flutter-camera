import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilterParamUiMapping', () {
    test('brightness/contrast/saturation/temperature/tint use factor 200', () {
      const params = FilterParams(
        brightness: 0.5,
        contrast: -0.5,
        saturation: 0.25,
        temperature: -0.25,
        tint: 0.1,
      );
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.brightness),
        100,
      );
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.contrast),
        -100,
      );
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.saturation),
        50,
      );
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.temperature),
        -50,
      );
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.tint),
        closeTo(20, 0.0001),
      );
    });

    test('exposure/fade use factor 100', () {
      const params = FilterParams(exposure: 1.0, fade: -1.0);
      expect(FilterParamUiMapping.toUi(params, FilterParamField.exposure), 100);
      expect(FilterParamUiMapping.toUi(params, FilterParamField.fade), -100);
    });

    test('hue uses factor 400', () {
      const params = FilterParams(hue: 0.25);
      expect(FilterParamUiMapping.toUi(params, FilterParamField.hue), 100);
    });

    test('smoothing maps 0..1 to 0..100 and has UI min of 0', () {
      const params = FilterParams(smoothing: 1.0);
      expect(
        FilterParamUiMapping.toUi(params, FilterParamField.smoothing),
        100,
      );
      expect(FilterParamUiMapping.uiMin(FilterParamField.smoothing), 0);
      expect(FilterParamUiMapping.uiMin(FilterParamField.brightness), -100);
    });

    test('toModel is the inverse of toUi for every field', () {
      const params = FilterParams(
        brightness: 0.3,
        contrast: -0.2,
        saturation: 0.1,
        exposure: 0.5,
        hue: -0.1,
        temperature: 0.4,
        tint: -0.3,
        fade: 0.6,
        smoothing: 0.7,
      );
      for (final field in FilterParamField.values) {
        final uiValue = FilterParamUiMapping.toUi(params, field).round();
        final modelValue = FilterParamUiMapping.toModel(field, uiValue);
        expect(
          modelValue,
          closeTo(FilterParamUiMapping.modelValue(params, field), 0.01),
          reason: 'round-trip mismatch for $field',
        );
      }
    });

    test('updateFromUi only changes the targeted field', () {
      const params = FilterParams(brightness: 0.1, contrast: 0.2);
      final updated = FilterParamUiMapping.updateFromUi(
        params,
        FilterParamField.saturation,
        50,
      );
      expect(updated.brightness, params.brightness);
      expect(updated.contrast, params.contrast);
      expect(updated.saturation, closeTo(0.25, 0.0001));
    });
  });
}
