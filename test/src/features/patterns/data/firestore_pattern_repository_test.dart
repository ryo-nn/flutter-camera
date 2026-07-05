import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patternFromFirestoreData', () {
    test('merges the document ID into the decoded Pattern', () {
      final data = <String, dynamic>{
        'ownerType': 'preset',
        'ownerUid': null,
        'name': 'ナチュラル盛り',
        'filterParams': {
          'brightness': 0.1,
          'contrast': 0.05,
          'saturation': 0.08,
          'exposure': 0.0,
          'hue': 0.0,
          'temperature': 0.05,
          'tint': 0.0,
          'fade': 0.1,
          'smoothing': 0.4,
        },
        'frameAssetId': 'frame-001',
        'stampLayers': <Map<String, dynamic>>[],
        'sortOrder': 0,
        'isPremium': false,
        'publishedAt': null,
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 7, 2)),
      };

      final pattern = patternFromFirestoreData(data, 'pattern-abc');

      expect(pattern.id, 'pattern-abc');
      expect(pattern.ownerType, PatternOwnerType.preset);
      expect(pattern.name, 'ナチュラル盛り');
      expect(pattern.frameAssetId, 'frame-001');
      expect(pattern.isPremium, isFalse);
    });

    test('defaults isPremium to false and publishedAt to null when absent '
        '(user-created patterns never send these fields)', () {
      final data = <String, dynamic>{
        'ownerType': 'user',
        'ownerUid': 'uid-1',
        'name': 'マイパターン',
        'filterParams': {
          'brightness': 0.0,
          'contrast': 0.0,
          'saturation': 0.0,
          'exposure': 0.0,
          'hue': 0.0,
          'temperature': 0.0,
          'tint': 0.0,
          'fade': 0.0,
          'smoothing': 0.0,
        },
        'stampLayers': <Map<String, dynamic>>[],
        'sortOrder': 0,
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 7, 1)),
      };

      final pattern = patternFromFirestoreData(data, 'pattern-xyz');

      expect(pattern.isPremium, isFalse);
      expect(pattern.publishedAt, isNull);
      expect(pattern.frameAssetId, isNull);
    });
  });
}
