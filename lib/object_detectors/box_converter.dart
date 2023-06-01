import 'package:flutter/material.dart';

class BoxConverter {
  static List<Rect> convert(
    List<List<double>> boxes, {
    required int height,
    required int width,
  }) {
    return boxes.map((e) {
      final List<double> box = e;
      return Rect.fromLTRB(
        box[1] * width,
        box[0] * height,
        box[3] * width,
        box[2] * height,
      );
    }).toList();
  }
}
