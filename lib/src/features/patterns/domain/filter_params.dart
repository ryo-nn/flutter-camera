import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_params.freezed.dart';
part 'filter_params.g.dart';

/// `patterns/{patternId}.filterParams`
///
/// 9パラメータ・値域は pro_image_editor の tune プリセットに準拠する
/// (design.md データモデル章 + カメラ・自動加工パイプライン設計章 §2.1 準拠。
/// 実際に運用中の `firestore.rules` `isValidFilterParams` と同一の値域)。
/// `smoothing` のみ tune 外のカスタムパラメータ(全面ブラーによる美肌補正近似)。
@freezed
sealed class FilterParams with _$FilterParams {
  const factory FilterParams({
    /// 明るさ: -0.5〜0.5(0.0 = 無補正)
    @Default(0.0) double brightness,

    /// コントラスト: -0.5〜0.5
    @Default(0.0) double contrast,

    /// 彩度: -0.5〜0.5
    @Default(0.0) double saturation,

    /// 露出: -1.0〜1.0
    @Default(0.0) double exposure,

    /// 色相: -0.25〜0.25
    @Default(0.0) double hue,

    /// 色温度: -0.5〜0.5
    @Default(0.0) double temperature,

    /// ティント: -0.5〜0.5
    @Default(0.0) double tint,

    /// フェード: -1.0〜1.0
    @Default(0.0) double fade,

    /// 美肌補正強度: 0.0〜1.0(カスタム実装。imagingセクション参照)
    @Default(0.0) double smoothing,
  }) = _FilterParams;

  factory FilterParams.fromJson(Map<String, Object?> json) =>
      _$FilterParamsFromJson(json);
}

/// S-06a のスライダー識別子(design.md 画面設計・UIフロー章 S-06a「フィルター」9本準拠。
/// 表示順もこの並びに従う)。
enum FilterParamField {
  brightness,
  contrast,
  saturation,
  exposure,
  hue,
  temperature,
  tint,
  fade,
  smoothing,
}

/// S-06a のスライダー表示値(-100〜+100。smoothingのみ0〜100)と
/// モデル値域(pro_image_editorのtuneプリセット準拠)の線形マッピング。
///
/// design.md データモデル章:「UIスライダーの表示値(-100〜+100)とモデル値域の変換は
/// pro_image_editorのlabelMultiplier(±0.5系は×200、hueは×400)に従う」。
/// この記述どおり、各フィールドの `factor = 100 / モデル値域の絶対値上限` として
/// 実装する(brightness/contrast/saturation/temperature/tint: ±0.5→factor 200,
/// exposure/fade: ±1.0→factor 100, hue: ±0.25→factor 400, smoothing: 0..1→factor 100)。
abstract final class FilterParamUiMapping {
  static const Map<FilterParamField, double> _factors = {
    FilterParamField.brightness: 200,
    FilterParamField.contrast: 200,
    FilterParamField.saturation: 200,
    FilterParamField.exposure: 100,
    FilterParamField.hue: 400,
    FilterParamField.temperature: 200,
    FilterParamField.tint: 200,
    FilterParamField.fade: 100,
    FilterParamField.smoothing: 100,
  };

  /// smoothing のみ 0〜100、他は -100〜+100(design.md S-06a 準拠)。
  static int uiMin(FilterParamField field) =>
      field == FilterParamField.smoothing ? 0 : -100;

  static const int uiMax = 100;

  static double modelValue(FilterParams params, FilterParamField field) {
    return switch (field) {
      FilterParamField.brightness => params.brightness,
      FilterParamField.contrast => params.contrast,
      FilterParamField.saturation => params.saturation,
      FilterParamField.exposure => params.exposure,
      FilterParamField.hue => params.hue,
      FilterParamField.temperature => params.temperature,
      FilterParamField.tint => params.tint,
      FilterParamField.fade => params.fade,
      FilterParamField.smoothing => params.smoothing,
    };
  }

  /// モデル値 → UI表示値(丸め込みは呼び出し側でスライダーの整数値へ変換する際に行う)。
  static double toUi(FilterParams params, FilterParamField field) {
    final factor = _factors[field]!;
    return modelValue(params, field) * factor;
  }

  /// UI表示値(整数) → モデル値。
  static double toModel(FilterParamField field, int uiValue) {
    final factor = _factors[field]!;
    return uiValue / factor;
  }

  /// 指定フィールドのみ UI 値で更新した新しい [FilterParams] を返す。
  static FilterParams updateFromUi(
    FilterParams params,
    FilterParamField field,
    int uiValue,
  ) {
    final modelValue = toModel(field, uiValue);
    return switch (field) {
      FilterParamField.brightness => params.copyWith(brightness: modelValue),
      FilterParamField.contrast => params.copyWith(contrast: modelValue),
      FilterParamField.saturation => params.copyWith(saturation: modelValue),
      FilterParamField.exposure => params.copyWith(exposure: modelValue),
      FilterParamField.hue => params.copyWith(hue: modelValue),
      FilterParamField.temperature => params.copyWith(temperature: modelValue),
      FilterParamField.tint => params.copyWith(tint: modelValue),
      FilterParamField.fade => params.copyWith(fade: modelValue),
      FilterParamField.smoothing => params.copyWith(smoothing: modelValue),
    };
  }

  /// スライダーの日本語ラベル(design.md 画面設計・UIフロー章 S-06a 準拠)。
  static String label(FilterParamField field) => switch (field) {
    FilterParamField.brightness => '明るさ',
    FilterParamField.contrast => 'コントラスト',
    FilterParamField.saturation => '彩度',
    FilterParamField.exposure => '露出',
    FilterParamField.hue => '色相',
    FilterParamField.temperature => '色温度',
    FilterParamField.tint => 'ティント',
    FilterParamField.fade => 'フェード',
    FilterParamField.smoothing => '美肌補正',
  };
}
