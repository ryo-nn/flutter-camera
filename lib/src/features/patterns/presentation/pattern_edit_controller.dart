import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pattern_edit_controller.g.dart';

/// パターンの作成・更新・削除の実行(対象はマイパターンのみ。プリセットは
/// 編集・削除不可)。(design.md アプリアーキテクチャ設計 Riverpod 3.0
/// プロバイダー設計「patternEditControllerProvider」family(`patternId?`))
///
/// `patternId == null` は新規作成(S-06a「新規作成」/「複製」)、
/// 非nullは既存マイパターンの更新・削除を表す。
@riverpod
class PatternEditController extends _$PatternEditController {
  @override
  Future<void> build(String? patternId) async {}

  /// 保存(新規作成 or 更新)。呼び出し前に画面側で
  /// `patternNameValidationError` によるバリデーションを行うこと。
  Future<void> save({
    required String name,
    required FilterParams filterParams,
    String? frameAssetId,
    required List<StampLayer> stampLayers,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patternRepositoryProvider);
      final id = patternId;
      if (id == null) {
        await repository.createPattern(
          name: name,
          filterParams: filterParams,
          frameAssetId: frameAssetId,
          stampLayers: stampLayers,
        );
      } else {
        await repository.updatePattern(
          patternId: id,
          name: name,
          filterParams: filterParams,
          frameAssetId: frameAssetId,
          stampLayers: stampLayers,
        );
      }
    });
  }

  /// 削除(S-06 一覧のオーバーフローメニュー「削除」から呼ばれる。マイパターンのみ)。
  Future<void> delete() async {
    final id = patternId;
    if (id == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(patternRepositoryProvider).deletePattern(id),
    );
  }
}

/// S-06「複製」導線で選択されたプリセットの初期値の受け渡し
/// (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を初期値とした
/// 新規作成)」準拠)。
///
/// `/patterns/new` ルート(実装済み `app_router.dart`)は `extra` を渡さないため、
/// S-06 が本プロバイダーへ複製元パターンをセットしてから遷移し、S-06a が
/// 読み取り後に [clear] する(design.mdに配置の明記が無いための実装判断。notes参照)。
@riverpod
class PatternDuplicateSource extends _$PatternDuplicateSource {
  @override
  Pattern? build() => null;

  void select(Pattern preset) => state = preset;

  void clear() => state = null;
}
