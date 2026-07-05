import 'package:flutter_camera/src/features/posting/domain/post.dart';

/// 投稿履歴一覧の取得を担うリポジトリの抽象インターフェース。
///
/// design.md アーキテクチャ章のディレクトリ構造コメントはhistory featureに
/// domain層を明示していないが(元は `presentation` + `data` のみ)、同章
/// 「レイヤー責務と依存方向」原則(presentationはdata層の具象クラスを直接
/// importせずdomainのインターフェース型で受ける)を満たすため本ファイルを追加する
/// (notes参照)。
abstract interface class PostHistoryRepository {
  /// ログイン中ユーザーの投稿履歴を新しい順に購読する
  /// (retention章「クエリとインデックス」節: 既存の複合インデックス
  /// `posts(userId ASC, createdAt DESC)` で充足するクエリ)。
  Stream<List<Post>> watchPostHistory();

  /// [uid] の投稿実績が1件でも存在するかを判定する(design.md 第9章
  /// 「S-04 初回投稿ガイド(コーチマーク)」: `posts.where('userId', isEqualTo: uid)
  /// .limit(1)` の存在チェック相当。onboarding featureの初回投稿ガイド表示判定用)。
  Future<bool> hasAnyPost(String uid);
}
