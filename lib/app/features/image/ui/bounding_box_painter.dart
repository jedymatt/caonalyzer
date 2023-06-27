import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:caonalyzer/object_detectors/object_detection_output.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<ObjectDetectionOutput> outputs;

  BoundingBoxPainter(this.outputs);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (var output in outputs) {
      final box =
          output.boundingBox.toPixel(size.height, size.width).toLTRBList();
      final rect = Rect.fromLTRB(box[0], box[1], box[2], box[3]);

      canvas.drawRect(rect, paint);

      final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.left,
      ))
        ..addText(
          '${output.label} ${(output.confidence * 100).toStringAsFixed(2)}%',
        );
      canvas.drawParagraph(paragraphBuilder.build(), Offset(box[0], box[1]));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
