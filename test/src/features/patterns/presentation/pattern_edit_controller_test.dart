import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:flutter_camera/src/features/patterns/presentation/pattern_edit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPatternRepository extends Mock implements PatternRepository {}

void main() {
  late MockPatternRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const FilterParams());
    registerFallbackValue(<StampLayer>[]);
  });

  setUp(() {
    repository = MockPatternRepository();
    container = ProviderContainer(
      overrides: [patternRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('PatternEditController.save', () {
    test('patternIdがnullなら新規作成(createPattern)を呼ぶ', () async {
      when(
        () => repository.createPattern(
          name: any(named: 'name'),
          filterParams: any(named: 'filterParams'),
          frameAssetId: any(named: 'frameAssetId'),
          stampLayers: any(named: 'stampLayers'),
        ),
      ).thenAnswer((_) async => 'new-id');

      container.read(patternEditControllerProvider(null));
      await container
          .read(patternEditControllerProvider(null).notifier)
          .save(
            name: 'ナチュラル',
            filterParams: const FilterParams(brightness: 0.1),
            frameAssetId: 'frame-1',
            stampLayers: const [],
          );

      final state = container.read(patternEditControllerProvider(null));
      expect(state.hasError, isFalse);
      verify(
        () => repository.createPattern(
          name: 'ナチュラル',
          filterParams: const FilterParams(brightness: 0.1),
          frameAssetId: 'frame-1',
          stampLayers: const [],
        ),
      ).called(1);
      verifyNever(
        () => repository.updatePattern(
          patternId: any(named: 'patternId'),
          name: any(named: 'name'),
          filterParams: any(named: 'filterParams'),
          frameAssetId: any(named: 'frameAssetId'),
          stampLayers: any(named: 'stampLayers'),
        ),
      );
    });

    test('patternIdがあれば既存パターンの更新(updatePattern)を呼ぶ', () async {
      when(
        () => repository.updatePattern(
          patternId: any(named: 'patternId'),
          name: any(named: 'name'),
          filterParams: any(named: 'filterParams'),
          frameAssetId: any(named: 'frameAssetId'),
          stampLayers: any(named: 'stampLayers'),
        ),
      ).thenAnswer((_) async {});

      container.read(patternEditControllerProvider('existing-id'));
      await container
          .read(patternEditControllerProvider('existing-id').notifier)
          .save(
            name: '更新後の名前',
            filterParams: const FilterParams(),
            frameAssetId: null,
            stampLayers: const [],
          );

      final state = container.read(
        patternEditControllerProvider('existing-id'),
      );
      expect(state.hasError, isFalse);
      verify(
        () => repository.updatePattern(
          patternId: 'existing-id',
          name: '更新後の名前',
          filterParams: const FilterParams(),
          frameAssetId: null,
          stampLayers: const [],
        ),
      ).called(1);
      verifyNever(
        () => repository.createPattern(
          name: any(named: 'name'),
          filterParams: any(named: 'filterParams'),
          frameAssetId: any(named: 'frameAssetId'),
          stampLayers: any(named: 'stampLayers'),
        ),
      );
    });

    test('リポジトリが失敗するとAsyncErrorになる', () async {
      when(
        () => repository.createPattern(
          name: any(named: 'name'),
          filterParams: any(named: 'filterParams'),
          frameAssetId: any(named: 'frameAssetId'),
          stampLayers: any(named: 'stampLayers'),
        ),
      ).thenThrow(Exception('network down'));

      container.read(patternEditControllerProvider(null));
      await container
          .read(patternEditControllerProvider(null).notifier)
          .save(
            name: 'エラーケース',
            filterParams: const FilterParams(),
            frameAssetId: null,
            stampLayers: const [],
          );

      final state = container.read(patternEditControllerProvider(null));
      expect(state.hasError, isTrue);
    });
  });

  group('PatternEditController.delete', () {
    test('family keyのpatternIdを指定してdeletePatternを呼ぶ', () async {
      when(() => repository.deletePattern(any())).thenAnswer((_) async {});

      container.read(patternEditControllerProvider('to-delete'));
      await container
          .read(patternEditControllerProvider('to-delete').notifier)
          .delete();

      verify(() => repository.deletePattern('to-delete')).called(1);
      final state = container.read(patternEditControllerProvider('to-delete'));
      expect(state.hasError, isFalse);
    });

    test('patternIdがnull(新規作成中)の場合は何もしない', () async {
      container.read(patternEditControllerProvider(null));
      await container
          .read(patternEditControllerProvider(null).notifier)
          .delete();

      verifyNever(() => repository.deletePattern(any()));
    });
  });
}
