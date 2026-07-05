import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';

/// 投稿作成 Functions 呼び出し(`snsPublishPost`)と `posts/{postId}` の購読を担う
/// リポジトリの抽象インターフェース(design.md アプリアーキテクチャ設計
/// 「レイヤー責務と依存方向」準拠。presentationはこの型のみに依存し、
/// data層の実装クラスを直接importしない)。
abstract interface class PostRepository {
  /// クライアント生成の冪等キー(`postId`)を発行する
  /// (backend章「冪等性」節: postIdはクライアント生成のUUID相当の一意な値であることを
  /// 要求する。実装はFirestoreの `doc()` によるネットワーク往復なしの自動採番IDを
  /// 用いる。coreChangeRequests参照)。
  String generatePostId();

  /// `snsPublishPost` onCall を呼び出す。
  ///
  /// [postId] / [imagePath] はクライアント生成の冪等キー
  /// (backend章「冪等性(同一投稿の二重実行防止)」節準拠)。
  /// タイムアウトは実装側(data層)で `HttpsCallableOptions(timeout: Duration(seconds: 600))`
  /// を明示すること(backend章「関数一覧」節: IGコンテナのポーリングにより応答まで
  /// 最大約6分かかり得るため、cloud_functionsプラグインの既定60秒タイムアウトでは
  /// 必ずクライアント側でタイムアウトする、との記載に対応)。
  ///
  /// 呼び出しが失敗した場合は [Exception]([AppException] 系)を throw する
  /// (エラーハンドリング方針準拠)。onCall応答を受け取れない異常時でも、
  /// 最終結果は [watchPost] のFirestoreリアルタイム購読で確定できる。
  ///
  /// [mediaType] は常に送信する('image' | 'video'。動画対応追加分)。
  /// [durationSec] / [fileSizeBytes] は動画投稿時のみ指定する(IG/Xのターゲット別
  /// バリデーションにサーバー側でも使用される想定。サーバー側の対応は別担当が
  /// 並行対応中のため、クライアントは契約どおり送るのみ)。
  Future<PublishPostOutcome> publishPost({
    required String postId,
    required String imagePath,
    required String caption,
    required bool instagram,
    required bool x,
    required String mediaType,
    String? patternId,
    bool force = false,
    String? deviceId,
    String? platform,
    double? durationSec,
    int? fileSizeBytes,
  });

  /// 投稿後のSNSごとステータス監視(`postStatusProvider` の購読対象)。
  Stream<Post> watchPost(String postId);
}

/// `snsPublishPost` の onCall レスポンス要約
/// (backend章 `PublishPostResult` 準拠)。ターゲットごとの詳細な状態は
/// [PostRepository.watchPost] のFirestore購読が唯一の正。
class PublishPostOutcome {
  const PublishPostOutcome({required this.postId, required this.overallStatus});

  final String postId;
  final PostOverallStatus overallStatus;
}
