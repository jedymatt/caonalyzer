import 'dart:math';

import 'package:image/image.dart' as imgLib;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class ScaleOp extends ImageOperator {
  final int _maxSize;
  final bool _useBilinear;

  ScaleOp(this._maxSize, ResizeMethod resizeMethod)
      : _useBilinear = resizeMethod == ResizeMethod.bilinear;

  @override
  TensorImage apply(TensorImage image) {
    imgLib.Image scaled = imgLib.copyResize(
      image.image,
      width: getOutputImageWidth(image.height, image.width),
      height: getOutputImageHeight(image.height, image.width),
      interpolation: _useBilinear
          ? imgLib.Interpolation.linear
          : imgLib.Interpolation.nearest,
    );

    return TensorImage.fromImage(scaled);
  }

  @override
  int getOutputImageHeight(int inputImageHeight, int inputImageWidth) {
    return _maxSize *
        inputImageHeight ~/
        max(inputImageHeight, inputImageWidth);
  }

  @override
  int getOutputImageWidth(int inputImageHeight, int inputImageWidth) {
    return _maxSize * inputImageWidth ~/ max(inputImageHeight, inputImageWidth);
  }

  @override
  Point<num> inverseTransform(
      Point<num> point, int inputImageHeight, int inputImageWidth) {
    return Point(
      point.x *
          inputImageWidth /
          getOutputImageWidth(inputImageHeight, inputImageWidth),
      point.y *
          inputImageHeight /
          getOutputImageHeight(inputImageHeight, inputImageWidth),
    );
  }
}
