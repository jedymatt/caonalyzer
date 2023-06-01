import 'dart:typed_data';

import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/box_converter.dart';
import 'package:caonalyzer/object_detectors/object_detection_output.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;

class ImageScreen extends StatelessWidget {
  const ImageScreen(this.image, this.output, {super.key});

  final imgLib.Image image;
  final ObjectDetectionOutput output;

  @override
  Widget build(BuildContext context) {
    // draw bounding boxes on image
    final boxes = BoxConverter.convert(
      output.detectionBoxes,
      height: image.height,
      width: image.width,
    );

    for (Rect box in boxes) {
      imgLib.drawRect(
        image,
        box.left.toInt(),
        box.top.toInt(),
        box.right.toInt(),
        box.bottom.toInt(),
        imgLib.getColor(0, 255, 0),
      );

      final label = labels[output.detectionClasses[boxes.indexOf(box)]];
      final score = output.detectionScores[boxes.indexOf(box)];

      imgLib.drawString(
        image,
        imgLib.arial_14,
        box.left.toInt(),
        box.top.toInt(),
        '$label ${(score * 100).toStringAsFixed(2)}%',
        color: imgLib.getColor(0, 255, 0),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.memory(imgLib.encodePng(image) as Uint8List),
              const SizedBox.square(
                dimension: 50,
              ),
              Text('${output.numDetections}'),
            ],
          ),
        ),
      ),
    );
  }
}
