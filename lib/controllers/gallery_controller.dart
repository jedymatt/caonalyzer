import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:get/get.dart';

import '../gallery/gallery_reader.dart';
import '../gallery/models/batch.dart';
import '../globals.dart' as globals;

class GalleryController extends GetxController {
  RxList<Batch> get batches => globals.batches;

  @override
  void onInit() {
    super.onInit();
    loadBatches();
  }

  void loadBatches() async => batches.value = await GalleryReader.getBatches();

  void deleteBatch(String batchDirPath) async {
    GalleryWriter.deleteDirectory(batchDirPath);
    batches.value = await GalleryReader.getBatches();
  }
}
