import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScaledCameraPreview extends StatelessWidget {
  final CameraController controller;

  const ScaledCameraPreview(this.controller, {super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * controller.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(
          key: super.key,
          controller,
          child: child,
        ),
      ),
    );
  }
}
