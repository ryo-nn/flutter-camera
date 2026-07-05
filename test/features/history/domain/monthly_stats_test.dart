import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/history/domain/monthly_stats.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_test/flutter_test.dart';

Post _post({
  required String id,
  required DateTime createdAt,
  PostOverallStatus overallStatus = PostOverallStatus.succeeded,
  String? patternId,
  String? patternName,
  PostTargetStatus igStatus = PostTargetStatus.succeeded,
  PostTargetStatus xStatus = PostTargetStatus.succeeded,
  bool igSelected = true,
  bool xSelected = true,
}) {
  return Post(
    id: id,
    userId: 'u1',
    imagePath: 'users/u1/postImages/$id.jpg',
    caption: '',
    patternId: patternId,
    patternName: patternName,
    instagram: PostTarget(
      provider: SnsProvider.instagram,
      selected: igSelected,
      status: igSelected ? igStatus : PostTargetStatus.skipped,
    ),
    x: PostTarget(
      provider: SnsProvider.x,
      selected: xSelected,
      status: xSelected ? xStatus : PostTargetStatus.skipped,
    ),
    overallStatus: overallStatus,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  final monthStart = DateTime.utc(2026, 7, 1);
  final beforeMonth = DateTime.utc(2026, 6, 30, 23, 59);
  final inMonth1 = DateTime.utc(2026, 7, 2);
  final inMonth2 = DateTime.utc(2026, 7, 3);
  final inMonth3 = DateTime.utc(2026, 7, 4);

  group('MonthlyStats.fromPosts', () {
    test('当月開始より前の投稿は集計から除外する', () {
      final posts = [
        _post(id: 'p0', createdAt: beforeMonth),
        _post(id: 'p1', createdAt: inMonth1),
      ];
      final stats = MonthlyStats.fromPosts(posts, monthStartJst: monthStart);
      expect(stats.totalPosts, 1);
    });

    test('overallStatusがfailedの投稿は今月の投稿数から除外する', () {
      final posts = [
        _post(
          id: 'p1',
          createdAt: inMonth1,
          overallStatus: PostOverallStatus.failed,
        ),
        _post(
          id: 'p2',
          createdAt: inMonth2,
          overallStatus: PostOverallStatus.succeeded,
        ),
        _post(
          id: 'p3',
          createdAt: inMonth3,
          overallStatus: PostOverallStatus.partial,
        ),
      ];
      final stats = MonthlyStats.fromPosts(posts, monthStartJst: monthStart);
      expect(stats.totalPosts, 2);
    });

    test('Instagram/X成功数はターゲットごとのstatusで数える', () {
      final posts = [
        _post(
          id: 'p1',
          createdAt: inMonth1,
          overallStatus: PostOverallStatus.partial,
          igStatus: PostTargetStatus.succeeded,
          xStatus: PostTargetStatus.failed,
        ),
        _post(
          id: 'p2',
          createdAt: inMonth2,
          overallStatus: PostOverallStatus.succeeded,
          igStatus: PostTargetStatus.succeeded,
          xStatus: PostTargetStatus.succeeded,
        ),
      ];
      final stats = MonthlyStats.fromPosts(posts, monthStartJst: monthStart);
      expect(stats.instagramSucceeded, 2);
      expect(stats.xSucceeded, 1);
    });

    test('patternIdがnull(加工なし)の投稿はランキング対象外', () {
      final posts = [
        _post(id: 'p1', createdAt: inMonth1),
        _post(id: 'p2', createdAt: inMonth2, patternId: null),
      ];
      final stats = MonthlyStats.fromPosts(posts, monthStartJst: monthStart);
      expect(stats.patternRanking, isEmpty);
    });

    test('パターンランキングは使用回数の多い順・上位3件', () {
      final posts = [
        _post(
          id: 'p1',
          createdAt: inMonth1,
          patternId: 'a',
          patternName: 'ナチュラル',
        ),
        _post(
          id: 'p2',
          createdAt: inMonth2,
          patternId: 'a',
          patternName: 'ナチュラル',
        ),
        _post(
          id: 'p3',
          createdAt: inMonth3,
          patternId: 'b',
          patternName: 'クール',
        ),
        _post(id: 'p4', createdAt: inMonth3, patternId: 'c', patternName: '甘め'),
        _post(
          id: 'p5',
          createdAt: inMonth3,
          patternId: 'd',
          patternName: 'モノクロ',
        ),
      ];
      final stats = MonthlyStats.fromPosts(posts, monthStartJst: monthStart);
      expect(stats.patternRanking, hasLength(3));
      expect(stats.patternRanking.first.patternId, 'a');
      expect(stats.patternRanking.first.count, 2);
    });

    test('投稿がなければ空の集計を返す', () {
      final stats = MonthlyStats.fromPosts(const [], monthStartJst: monthStart);
      expect(stats.totalPosts, 0);
      expect(stats.instagramSucceeded, 0);
      expect(stats.xSucceeded, 0);
      expect(stats.patternRanking, isEmpty);
    });
  });
}
