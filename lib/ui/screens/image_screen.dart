import 'package:caonalyzer/object_detectors/object_detectors.dart';
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
      image_lib.drawRect(
        image,
        x1: output.boundingBox.left.toInt(),
        y1: output.boundingBox.top.toInt(),
        x2: output.boundingBox.right.toInt(),
        y2: output.boundingBox.bottom.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        thickness: 2,
      );

      final label = output.label;
      final score = output.confidence;

      image_lib.drawString(
        image,
        '$label ${(score * 100).toStringAsFixed(2)}%',
        font: image_lib.arial14,
        x: output.boundingBox.left.toInt(),
        y: output.boundingBox.top.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        wrap: true,
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
