import 'package:flutter_camera/src/core/models/asset.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';

/// パターンリポジトリの抽象インターフェース。
///
/// data 層(`FirestorePatternRepository`)が実装を提供し、`patternRepositoryProvider`
/// (data/firestore_pattern_repository.dart)経由で DI する。presentation 層は
/// 本インターフェース型のみに依存する
/// (design.md アプリアーキテクチャ設計「レイヤー責務と依存方向」準拠)。
///
/// SDK例外(`FirebaseException` 等)は実装側で `AppException`
/// (`core/error/app_exception.dart`)へ変換して throw する。
abstract interface class PatternRepository {
  /// 運営プリセット一覧の購読(`ownerType == 'preset'`。編集・削除不可)。
  Stream<List<Pattern>> watchPresetPatterns();

  /// ログイン中ユーザーのマイパターン一覧の購読(`ownerType == 'user'` かつ自uid)。
  /// 未ログイン時は空リストのStreamを返す。
  Stream<List<Pattern>> watchUserPatterns();

  /// 単一パターンの取得(S-06a 編集画面の初期値ロード用)。
  /// プリセット・マイパターンいずれも対象(Rulesの read 条件を満たす場合のみ成功)。
  Future<Pattern> fetchPattern(String patternId);

  /// マイパターンを新規作成する。戻り値は作成されたドキュメントID。
  /// `ownerType`(user固定)/ `ownerUid`(自uid) / `sortOrder`(0固定) は
  /// 実装側が付与し、呼び出し側からは渡さない
  /// (Firestore Security Rulesの `hasOnly` 制約と対応)。
  Future<String> createPattern({
    required String name,
    required FilterParams filterParams,
    String? frameAssetId,
    required List<StampLayer> stampLayers,
  });

  /// マイパターンを更新する(対象はマイパターンのみ。プリセットは編集不可)。
  Future<void> updatePattern({
    required String patternId,
    required String name,
    required FilterParams filterParams,
    String? frameAssetId,
    required List<StampLayer> stampLayers,
  });

  /// マイパターンを削除する(対象はマイパターンのみ)。
  Future<void> deletePattern(String patternId);

  /// S-06a フレーム選択タブで選択可能な素材一覧(`assets` コレクション、
  /// `type == 'frame'`)。ユーザー作成パターンにプレミアム素材を含めると、
  /// 非Proユーザーが適用時に Storage Rules で弾かれる不整合が生じるため、
  /// `isPremium == false` の素材のみを返す(design.md に明記が無いための
  /// 実装判断。notes参照)。
  Stream<List<Asset>> watchSelectableFrameAssets();

  /// S-06a スタンプ選択タブで選択可能な素材一覧(`assets` コレクション、
  /// `type == 'stamp'`)。[watchSelectableFrameAssets] と同様の理由で
  /// `isPremium == false` の素材のみを返す。
  Stream<List<Asset>> watchSelectableStampAssets();
}

/// プリセット→マイパターンの順に連結する(design.md アプリアーキテクチャ設計
/// `patternsProvider` の責務準拠)。純粋関数として切り出し単体テスト可能にする。
List<Pattern> combinePresetAndUserPatterns({
  required List<Pattern> presets,
  required List<Pattern> userPatterns,
}) => [...presets, ...userPatterns];

/// S-06a パターン名バリデーション(design.md 画面設計・UIフロー章 S-06a
/// 「バリデーションエラー」+ データモデル章「name(1〜50文字)」準拠)。
/// エラーが無ければ `null` を返す(`TextFormField.validator` にそのまま渡せる形)。
String? patternNameValidationError(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'パターン名を入力してください';
  }
  if (trimmed.length > PatternNameLimits.maxLength) {
    return 'パターン名は${PatternNameLimits.maxLength}文字以内で入力してください';
  }
  return null;
}
