import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/history/domain/first_successful_post.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_test/flutter_test.dart';

Post _post({
  required String id,
  PostOverallStatus overallStatus = PostOverallStatus.succeeded,
}) {
  return Post(
    id: id,
    userId: 'u1',
    imagePath: 'users/u1/postImages/$id.jpg',
    caption: '',
    instagram: const PostTarget(
      provider: SnsProvider.instagram,
      selected: true,
      status: PostTargetStatus.succeeded,
    ),
    x: const PostTarget(
      provider: SnsProvider.x,
      selected: false,
      status: PostTargetStatus.skipped,
    ),
    overallStatus: overallStatus,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

void main() {
  group('isCountedAsSuccessfulPost', () {
    test('overallStatusがsucceededの場合はtrue', () {
      expect(
        isCountedAsSuccessfulPost(
          _post(id: 'p1', overallStatus: PostOverallStatus.succeeded),
        ),
        isTrue,
      );
    });

    test('overallStatusがpartialの場合はtrue(一部成功も完了扱い)', () {
      expect(
        isCountedAsSuccessfulPost(
          _post(id: 'p1', overallStatus: PostOverallStatus.partial),
        ),
        isTrue,
      );
    });

    test('overallStatusがfailedの場合はfalse', () {
      expect(
        isCountedAsSuccessfulPost(
          _post(id: 'p1', overallStatus: PostOverallStatus.failed),
        ),
        isFalse,
      );
    });

    test('overallStatusがprocessingの場合はfalse', () {
      expect(
        isCountedAsSuccessfulPost(
          _post(id: 'p1', overallStatus: PostOverallStatus.processing),
        ),
        isFalse,
      );
    });
  });

  group('isFirstSuccessfulPost', () {
    test('投稿が0件ならfalse', () {
      expect(isFirstSuccessfulPost(const []), isFalse);
    });

    test('成功投稿が1件のみならtrue(=初回投稿が今回成功した)', () {
      final posts = [_post(id: 'p1', overallStatus: PostOverallStatus.succeeded)];
      expect(isFirstSuccessfulPost(posts), isTrue);
    });

    test('成功投稿が2件以上ならfalse(既に初回を消化済み)', () {
      final posts = [
        _post(id: 'p1', overallStatus: PostOverallStatus.succeeded),
        _post(id: 'p2', overallStatus: PostOverallStatus.partial),
      ];
      expect(isFirstSuccessfulPost(posts), isFalse);
    });

    test('失敗のみの投稿が何件あってもfalse(成功実績がまだない)', () {
      final posts = [
        _post(id: 'p1', overallStatus: PostOverallStatus.failed),
        _post(id: 'p2', overallStatus: PostOverallStatus.failed),
      ];
      expect(isFirstSuccessfulPost(posts), isFalse);
    });

    test('失敗の後に初めて成功した場合はtrue(失敗は判定に影響しない)', () {
      final posts = [
        _post(id: 'p2', overallStatus: PostOverallStatus.succeeded),
        _post(id: 'p1', overallStatus: PostOverallStatus.failed),
      ];
      expect(isFirstSuccessfulPost(posts), isTrue);
    });
  });
}
