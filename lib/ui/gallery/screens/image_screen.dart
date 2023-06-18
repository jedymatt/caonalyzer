import 'dart:io';
import 'dart:typed_data';

import 'package:caonalyzer/controllers/image_screen_controller.dart';
import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image/image.dart' as image_lib;

class ImageScreen extends StatefulWidget {
  const ImageScreen(this.images, {super.key, this.initialIndex = 0});

  final List<String> images;
  final int initialIndex;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late ImageScreenController controller;
  late final PageController _pageController;
  late String imageTitle;
  late int currentIndex;
  late final List<Uint8List> decodedImages;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    imageTitle = '${currentIndex + 1}/${widget.images.length}';
    _pageController = PageController(initialPage: widget.initialIndex);

    controller = Get.put(ImageScreenController(
      widget.images,
      initialIndex: widget.initialIndex,
    ));

    // initDecodedImages();
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<ImageScreenController>();
  }

  void initDecodedImages() {
    decodedImages = widget.images.map((image) {
      var decodedImage = image_lib.decodeJpg(File(image).readAsBytesSync())!;
      final metadata = MetadataReader.read(image);

      if (decodedImage.width > decodedImage.height) {
        decodedImage = image_lib.copyResize(decodedImage,
            width: 640, interpolation: image_lib.Interpolation.linear);
      } else {
        decodedImage = image_lib.copyResize(decodedImage,
            height: 640, interpolation: image_lib.Interpolation.linear);
      }

      if (metadata != null) {
        for (var output in metadata.objectDetectionOutputs) {
          output = output.toPixelBoxes(decodedImage.height, decodedImage.width);

          image_lib.drawRect(
            decodedImage,
            x1: output.boxes[0].toInt(),
            y1: output.boxes[1].toInt(),
            x2: output.boxes[2].toInt(),
            y2: output.boxes[3].toInt(),
            color: image_lib.ColorRgb8(255, 0, 0),
            thickness: 3,
          );

          image_lib.drawString(
            decodedImage,
            '${output.class_} ${output.confidence.toStringAsFixed(2)}%',
            font: image_lib.arial14,
            x: output.boxes[0].toInt(),
            y: output.boxes[1].toInt(),
            color: image_lib.ColorRgb8(255, 0, 0),
          );
        }
      }

      return image_lib.encodeJpg(decodedImage);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${currentIndex + 1}/${widget.images.length}',
        ),
        centerTitle: true,
        bottom: widget.images.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / widget.images.length,
                ),
              )
            : null,
      ),
      body: PhotoViewGallery(
        pageController: controller.pageController,
        pageOptions: controller.images
            .map(
              (image) => PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(image)),
                heroAttributes: PhotoViewHeroAttributes(tag: image),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
            )
            .toList(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        onPageChanged: (index) {
          debugPrint('index: $index picturesLength: ${widget.images.length}');
          setState(() {
            currentIndex = index;
            imageTitle = '${currentIndex + 1}/${widget.images.length}';
          });
        },
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.background,
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: controller.deleteCurrentImage,
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: controller.scanCurrentImage,
              icon: const Icon(Icons.scanner),
            ),
          ],
        ),
      ),
      bottomSheet: controller.showingResultSheet.value
          ? BottomSheet(
              onClosing: controller.closeResultSheet,
              builder: (context) => SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Text(
                          'Result',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(controller
                                .currentImageMetadata!.objectDetectionMode),
                          ),
                        ),
                      ],
                    ),
                  ))
          : null,
    );
  }
}
