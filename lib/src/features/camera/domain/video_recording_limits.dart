/// S-04動画撮影モードの録画時間制約(純Dart・Flutter/SDK非依存)。
///
/// 録画開始時刻と現在時刻の差分から、経過秒数の算出と140秒到達時の自動停止判定を行う。
/// 実際のカウントダウン(`Timer.periodic`)はpresentation層(`CameraScreen`)が担い、
/// 本クラスは判定ロジックのみを提供することでユニットテスト可能にする。
abstract final class VideoRecordingLimits {
  const VideoRecordingLimits._();

  /// 動画撮影の自動停止までの上限時間。
  static const Duration maxDuration = Duration(seconds: 140);

  /// [startedAt] から [now] までの経過時間が [maxDuration] に達したかどうか。
  static bool shouldAutoStop(DateTime startedAt, DateTime now) {
    return now.difference(startedAt) >= maxDuration;
  }

  /// [startedAt] から [now] までの経過秒数(UI表示用。切り捨て)。
  static int elapsedSeconds(DateTime startedAt, DateTime now) {
    final elapsed = now.difference(startedAt);
    return elapsed.isNegative ? 0 : elapsed.inSeconds;
  }
}
