import 'package:caonalyzer/object_detectors/types/object_detection_output.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;

class ImageScreen extends StatelessWidget {
  const ImageScreen(this.image, this.outputs, {super.key});

  final image_lib.Image image;
  final List<ObjectDetectionOutput> outputs;

  @override
  Widget build(BuildContext context) {
    // draw bounding boxes on image
    for (var output in outputs) {
      final box = output.boundingBox.toAbsoluteBoundingBox(
        image.width,
        image.height,
      );

      image_lib.drawRect(
        image,
        x1: box.left.toInt(),
        y1: box.top.toInt(),
        x2: box.right.toInt(),
        y2: box.bottom.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        thickness: 2,
      );

      final label = output.label;
      final score = output.confidence;

      image_lib.drawString(
        image,
        font: image_lib.arial14,
        x: box.left.toInt(),
        y: box.top.toInt(),
        '$label ${(score * 100).toStringAsFixed(2)}%',
        color: image_lib.ColorRgb8(0, 255, 0),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: InteractiveViewer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.memory(image_lib.encodePng(image)),
            ),
            Text('Outputs count: ${outputs.length}'),
          ],
        ),
      ),
    );
  }
}
