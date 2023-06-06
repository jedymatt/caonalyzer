import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;

class ImagePreviewScreen extends StatefulWidget {
  final image_lib.Image image;
  final List<ObjectDetectionOutput>? objectDetectionOutputs;

  const ImagePreviewScreen(
    this.image, {
    super.key,
    this.objectDetectionOutputs,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool showOverlay = false;

  @override
  Widget build(BuildContext context) {
    for (ObjectDetectionOutput output in widget.objectDetectionOutputs ?? []) {
      BoundingBox boundingBox = output.boundingBox.toPixel(
        widget.image.height,
        widget.image.width,
      );

      image_lib.drawRect(
        widget.image,
        x1: boundingBox.left.toInt(),
        y1: boundingBox.top.toInt(),
        x2: boundingBox.right.toInt(),
        y2: boundingBox.bottom.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        // thicknes should be relative to image size
        thickness: widget.image.width ~/ 300,
      );

      final label = output.label;
      final score = output.confidence;

      image_lib.drawString(
        widget.image,
        '$label ${(score * 100).toStringAsFixed(2)}%',
        font: image_lib.arial14,
        x: boundingBox.left.toInt(),
        y: boundingBox.top.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        wrap: true,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showOverlay = !showOverlay;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExtendedImage.memory(
                image_lib.encodeJpg(widget.image),
                clearMemoryCacheWhenDispose: true,
                clearMemoryCacheIfFailed: true,
                onDoubleTap: (state) => {state.reset()},
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 1,
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
