import 'dart:typed_data';

import 'package:caonalyzer/object_detectors/box_converter.dart';
import 'package:caonalyzer/object_detectors/object_detection_output.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageScreen extends StatelessWidget {
  const ImageScreen(this.image, this.objectDetectionOutput, {super.key});

  final img.Image image;
  final ObjectDetectionOutput objectDetectionOutput;

  @override
  Widget build(BuildContext context) {
    // draw bounding boxes on image
    final boxes = BoxConverter.convert(
      objectDetectionOutput.detectionBoxes,
      height: image.height,
      width: image.width,
    );

    for (Rect box in boxes) {
      img.drawRect(
        image,
        box.left.toInt(),
        box.top.toInt(),
        box.right.toInt(),
        box.bottom.toInt(),
        img.getColor(0, 255, 0),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.memory(img.encodePng(image) as Uint8List),
              const SizedBox.square(
                dimension: 50,
              ),
              Text(objectDetectionOutput.numDetections.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
