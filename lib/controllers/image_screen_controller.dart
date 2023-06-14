import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:caonalyzer/gallery/models/image_metadata.dart';
import 'package:get/get.dart';
import 'package:caonalyzer/globals.dart' as globals;
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as image_lib;

import '../gallery/metadata_writer.dart';

class ImageScreenController extends GetxController {
  final RxString imagePath = ''.obs;
  final Rx<ImageMetadata?> imageMetadata = null.obs;

  void loadImagePath(String imagePath_) {
    imagePath.value = imagePath_;
    imageMetadata.value = MetadataReader.read(imagePath_);
  }

  void rescanImage() async {
    final objectDetector = globals.preferredMode.value.objectDetector;

    final tensorImage = objectDetector.preprocessImage(
      (await image_lib.decodeJpgFile(imagePath.value))!,
    );
    final output = await objectDetector.runInference(tensorImage);

    var metadata = ImageMetadata(
      imagePath: imagePath.value,
      objectDetectionMode: globals.preferredMode.value.toString(),
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

    MetadataWriter.create(
      imagePath.value,
      metadata,
    );
  }
}
