import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_camera/src/features/editor/domain/pattern_apply_service.dart';
import 'package:path_provider/path_provider.dart';

/// 撮影後の正規化(4:5センタークロップ+幅1440px上限。design.md「カメラ・自動加工
/// パイプライン設計」§5準拠)。
///
/// カメラは4:5で撮影できない(センサーは4:3/16:9)ため、pro_image_editor投入前に
/// dart:uiで確定的にクロップする。中間フォーマットはJPEG二重圧縮を避けるためロスレスPNG。
/// `dart:ui` 制約(spawnされたisolateでは使用不可。docs.flutter.dev/perf/isolates)により
/// ルートisolateで実行する(§3.4)。
class ImageNormalizationService {
  const ImageNormalizationService();

  Future<NormalizedImage> normalizeCapture(String sourceImagePath) async {
    final bytes = await File(sourceImagePath).readAsBytes();

    // 1) 実寸取得(フルデコード前にImageDescriptorで寸法だけ読む)
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final needsDownscale = descriptor.width > 1440;

    // 2) 幅1440上限でダウンサンプルデコード(§6)
    final codec = await descriptor.instantiateCodec(
      targetWidth: needsDownscale ? 1440 : descriptor.width,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // 3) 4:5 (width/height = 0.8) センタークロップ
    final srcW = image.width.toDouble();
    final srcH = image.height.toDouble();
    var cropW = srcW;
    var cropH = srcW * 5 / 4;
    if (cropH > srcH) {
      cropH = srcH;
      cropW = srcH * 4 / 5;
    }
    final src = ui.Rect.fromLTWH(
      (srcW - cropW) / 2,
      (srcH - cropH) / 2,
      cropW,
      cropH,
    );

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      src,
      ui.Rect.fromLTWH(0, 0, cropW, cropH),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final cropped = await recorder.endRecording().toImage(
      cropW.round(),
      cropH.round(),
    );
    final png = await cropped.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    cropped.dispose();

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/capture_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(png!.buffer.asUint8List(), flush: true);

    return NormalizedImage(
      filePath: path,
      width: cropW.roundToDouble(),
      height: cropH.roundToDouble(),
    );
  }
}
