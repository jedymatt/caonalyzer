import 'package:caonalyzer/object_detectors/models/object_detection_output.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:caonalyzer/object_detectors/widgets/box_painter.dart'
    as painter;

class ImageScreen extends StatelessWidget {
  const ImageScreen(this.image, this.objectDetectionOutputs, {super.key});

  final img.Image image;
  final List<ObjectDetectionOutput> objectDetectionOutputs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: CustomPaint(
          painter: painter.BoxPainter(
            objectDetectionOutputs,
            image.width.toDouble(),
            image.height.toDouble(),
          ),
          child: image.getBytes().isNotEmpty
              ? Image.memory(image.getBytes())
              : const Text('No image'),
        ),
      ),
    );
  }
}
