import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:caonalyzer/gallery/models/image_metadata.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:caonalyzer/globals.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path_lib;

import '../gallery/metadata_writer.dart';

class ImageScreenController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final List<String> images;
  late final List<ImageMetadata?> metadataImages;
  late final PageController pageController;
  final showingResultSheet = false.obs;

  ImageScreenController(this.images, {int initialIndex = 0}) {
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  void onInit() {
    super.onInit();

    metadataImages = images.map((e) => MetadataReader.read(e)).toList();
  }

  void deleteCurrentImage() {
    final imagePath = images[currentIndex.value];

    if (MetadataReader.read(imagePath) != null) {
      MetadataWriter.delete(imagePath);
    }

    GalleryWriter.removeImages([imagePath]);

    images.removeAt(currentIndex.value);
    metadataImages.removeAt(currentIndex.value);

    if (images.isEmpty) {
      final dirPath = path_lib.dirname(imagePath);
      Globals.batches.removeWhere((element) => element.dirPath == dirPath);

      Get.until((route) => route.isFirst);

      return;
    }

    if (currentIndex.value == images.length) {
      currentIndex.value--;
    }

    pageController.jumpToPage(currentIndex.value);
  }

  void scanCurrentImage() async {
    final imagePath = images[currentIndex.value];

    final metadata = MetadataReader.read(imagePath);

    if (metadata == null) {
      final objectDetector = Globals.preferredMode.value.objectDetector;
      final tensorImage = objectDetector.preprocessImage(
        (await image_lib.decodeJpgFile(imagePath))!,
      );
      final output = await objectDetector.runInference(tensorImage);

      var metadata = ImageMetadata(
        imagePath: imagePath,
        objectDetectionMode: Globals.preferredMode.value.toString(),
        objectDetectionOutputs: output
            .map((e) => ObjectDetectionOutput(
                  class_: e.label,
                  confidence: e.confidence,
                  boxes: [
                    e.boundingBox.left,
                    e.boundingBox.top,
                    e.boundingBox.right,
                    e.boundingBox.bottom,
                  ],
                ))
            .toList(),
      );

      metadataImages[currentIndex.value] = metadata;
    } else {
      showingResultSheet.value = true;
    }
  }

  void closeResultSheet() {
    showingResultSheet.value = false;
  }

  ImageMetadata? get currentImageMetadata => metadataImages[currentIndex.value];
}
