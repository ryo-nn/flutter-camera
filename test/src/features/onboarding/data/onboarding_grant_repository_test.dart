import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/features/onboarding/data/onboarding_grant_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  const uid = 'user-1';

  late _MockFirebaseFirestore firestore;
  late _MockCollectionReference collection;
  late _MockDocumentReference document;
  late OnboardingGrantRepository repository;

  setUp(() {
    firestore = _MockFirebaseFirestore();
    collection = _MockCollectionReference();
    document = _MockDocumentReference();

    when(() => firestore.collection('onboardingGrants')).thenReturn(
      collection,
    );
    when(() => collection.doc(uid)).thenReturn(document);

    repository = OnboardingGrantRepository(firestore);
  });

  group('OnboardingGrantRepository.watch', () {
    test('ドキュメントが存在しない場合は null を返す(保証未消費)', () async {
      final snapshot = _MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(null);
      when(
        () => document.snapshots(),
      ).thenAnswer((_) => Stream.value(snapshot));

      final result = await repository.watch(uid).first;

      expect(result, isNull);
    });

    test('ドキュメントが存在する場合は OnboardingGrant に変換する', () async {
      final firstPostUsedAt = DateTime(2026, 7, 1, 12);
      final updatedAt = DateTime(2026, 7, 1, 12, 5);
      final snapshot = _MockDocumentSnapshot();
      when(() => snapshot.id).thenReturn(uid);
      when(() => snapshot.data()).thenReturn({
        'uid': uid,
        'firstPostUsedAt': Timestamp.fromDate(firstPostUsedAt),
        'firstPostId': 'post-1',
        'updatedAt': Timestamp.fromDate(updatedAt),
      });
      when(
        () => document.snapshots(),
      ).thenAnswer((_) => Stream.value(snapshot));

      final result = await repository.watch(uid).first;

      expect(result?.uid, uid);
      expect(result?.firstPostId, 'post-1');
      expect(result?.firstPostUsedAt, firstPostUsedAt);
      expect(result?.updatedAt, updatedAt);
    });
  });
}
