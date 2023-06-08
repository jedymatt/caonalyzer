import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;

class ViewImageScreen extends StatefulWidget {
  final image_lib.Image image;
  final List<ObjectDetectionOutput>? objectDetectionOutputs;

  const ViewImageScreen(
    this.image, {
    super.key,
    this.objectDetectionOutputs,
  });

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.objectDetectionOutputs != null) {
      drawBoundingBoxes(widget.image, widget.objectDetectionOutputs!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
    );
  }

  void drawBoundingBoxes(
      image_lib.Image image, List<ObjectDetectionOutput> outputs) {
    if (outputs.isEmpty) return;

    for (final output in widget.objectDetectionOutputs!) {
      final boundingBox = output.boundingBox.toPixel(
        image.height,
        image.width,
      );

      image_lib.drawRect(
        image,
        x1: boundingBox.left.toInt(),
        y1: boundingBox.top.toInt(),
        x2: boundingBox.right.toInt(),
        y2: boundingBox.bottom.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        thickness: 2,
      );

      image_lib.drawString(
        image,
        '${output.label} ${(output.confidence * 100).toStringAsFixed(2)}%',
        font: image_lib.arial14,
        x: boundingBox.left.toInt(),
        y: boundingBox.top.toInt(),
        color: image_lib.ColorRgb8(0, 255, 0),
        wrap: true,
      );
    }
  }
}
