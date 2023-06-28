import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:caonalyzer/app/features/image/models/image.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectedObject> outputs;

  BoundingBoxPainter(this.outputs);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (var output in outputs) {
      final box = output.absoluteBoundingBox(size.height, size.width);
      final rect = Rect.fromLTRB(box[0], box[1], box[2], box[3]);

      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: output.displayLabel,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          rect.left,
          rect.top - textPainter.height - 4.0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.outputs != outputs ||
        oldDelegate.outputs.isEmpty != outputs.isEmpty;
  }
}
