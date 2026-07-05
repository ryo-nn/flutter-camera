import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';

/// S-06a「フィルター」タブ: 縦スクロールのスライダーリスト9本
/// (design.md 画面設計・UIフロー章 S-06a準拠。各スライダーに数値表示+リセットアイコン)。
class FilterParamSliders extends StatelessWidget {
  const FilterParamSliders({
    super.key,
    required this.filterParams,
    required this.onChanged,
  });

  final FilterParams filterParams;
  final ValueChanged<FilterParams> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: FilterParamField.values
          .map(
            (field) => _FilterParamSlider(
              field: field,
              filterParams: filterParams,
              onChanged: onChanged,
            ),
          )
          .toList(),
    );
  }
}

class _FilterParamSlider extends StatelessWidget {
  const _FilterParamSlider({
    required this.field,
    required this.filterParams,
    required this.onChanged,
  });

  final FilterParamField field;
  final FilterParams filterParams;
  final ValueChanged<FilterParams> onChanged;

  @override
  Widget build(BuildContext context) {
    final uiValue = FilterParamUiMapping.toUi(filterParams, field).round();
    final min = FilterParamUiMapping.uiMin(field);
    const max = FilterParamUiMapping.uiMax;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              FilterParamUiMapping.label(field),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Slider(
              value: uiValue.toDouble().clamp(min.toDouble(), max.toDouble()),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: '$uiValue',
              onChanged: (value) => onChanged(
                FilterParamUiMapping.updateFromUi(
                  filterParams,
                  field,
                  value.round(),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$uiValue',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Semantics(
            button: true,
            label: '${FilterParamUiMapping.label(field)}をリセット',
            child: IconButton(
              icon: const Icon(Icons.replay, size: 18),
              onPressed: uiValue == 0
                  ? null
                  : () => onChanged(
                      FilterParamUiMapping.updateFromUi(filterParams, field, 0),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
