/// S-04ホーム/撮影画面の写真/動画モード切替トグルが選択する撮影モード。
///
/// [CameraSession] はモードに応じて `CameraController` を異なる設定
/// (写真: `enableAudio: false` / 動画: `enableAudio: true` かつ
/// `ResolutionPreset.hd`)で再初期化する。
enum CameraCaptureMode {
  /// 静止画撮影(既定モード。既存の自撮り撮影フローと同一設定)。
  photo,

  /// 動画撮影(140秒で自動停止。S-05vへ遷移する)。
  video,
}
