import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/globals.dart';
import 'package:get/get.dart';

class ViewBatchScreenController extends GetxController {
  final images = <String>[].obs;
  final selectedImages = <String>[].obs;
  final isSelecting = false.obs;

  final Batch batch;

  ViewBatchScreenController(this.batch);

  @override
  void onInit() {
    super.onInit();

    images.value = GalleryReader.getImagesFromBatch(batch.dirPath);
  }

  void toggleSelect(String image) {
    if (selectedImages.contains(image)) {
      selectedImages.remove(image);
    } else {
      selectedImages.add(image);
    }
  }

  void selectAll() {
    selectedImages.value = images;
  }

  void deselectAll() {
    selectedImages.value = [];
  }

  void deleteSelected() {
    GalleryWriter.removeImages(selectedImages);

    images.value = GalleryReader.getImagesFromBatch(batch.dirPath);
    selectedImages.value = [];
    isSelecting.value = false;

    if (images.isEmpty) {
      Globals.batches.remove(batch);

      Get.back();
    }
  }

  void toggleSelecting() => isSelecting.value = !isSelecting.value;

  void stopSelecting() {
    isSelecting.value = false;
    selectedImages.value = [];
  }
}
