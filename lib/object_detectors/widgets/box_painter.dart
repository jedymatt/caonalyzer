import 'package:caonalyzer/object_detectors/models/object_detection_output.dart';
import 'package:flutter/material.dart';

class BoxPainter extends CustomPainter {
  final List<ObjectDetectionOutput> outputs;
  final double width;
  final double height;

  BoxPainter(this.outputs, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final output in outputs) {
      final rect = Rect.fromLTRB(
        output.x * width,
        output.y * height,
        output.width * width,
        output.height * height,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BoxPainter oldDelegate) => true;
}
