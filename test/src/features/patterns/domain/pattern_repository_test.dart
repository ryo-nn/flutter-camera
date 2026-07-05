import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Pattern _pattern({
  required String id,
  required PatternOwnerType ownerType,
  String? ownerUid,
}) {
  final now = DateTime(2026, 7, 4);
  return Pattern(
    id: id,
    ownerType: ownerType,
    ownerUid: ownerUid,
    name: 'テストパターン $id',
    filterParams: const FilterParams(),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('combinePresetAndUserPatterns', () {
    test('presets come first, then user patterns, in given order', () {
      final preset1 = _pattern(id: 'p1', ownerType: PatternOwnerType.preset);
      final preset2 = _pattern(id: 'p2', ownerType: PatternOwnerType.preset);
      final user1 = _pattern(
        id: 'u1',
        ownerType: PatternOwnerType.user,
        ownerUid: 'uid-1',
      );

      final combined = combinePresetAndUserPatterns(
        presets: [preset1, preset2],
        userPatterns: [user1],
      );

      expect(combined.map((p) => p.id), ['p1', 'p2', 'u1']);
    });

    test('returns an empty list when both inputs are empty', () {
      final combined = combinePresetAndUserPatterns(
        presets: const [],
        userPatterns: const [],
      );
      expect(combined, isEmpty);
    });
  });

  group('patternNameValidationError', () {
    test('rejects null and empty/whitespace-only input', () {
      expect(patternNameValidationError(null), 'パターン名を入力してください');
      expect(patternNameValidationError(''), 'パターン名を入力してください');
      expect(patternNameValidationError('   '), 'パターン名を入力してください');
    });

    test('rejects names longer than 50 characters', () {
      final tooLong = 'あ' * 51;
      expect(patternNameValidationError(tooLong), 'パターン名は50文字以内で入力してください');
    });

    test('accepts valid names at the boundary (1 and 50 chars)', () {
      expect(patternNameValidationError('あ'), isNull);
      expect(patternNameValidationError('あ' * 50), isNull);
    });
  });
}
