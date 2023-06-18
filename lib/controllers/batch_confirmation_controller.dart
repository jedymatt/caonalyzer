import 'package:caonalyzer/controllers/gallery_controller.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/globals.dart';
import 'package:get/get.dart';

import '../gallery/gallery_writer.dart';
import '../ui/gallery/screens/view_batch_screen.dart';
import 'package:path/path.dart' as path_lib;

class BatchConfirmationController extends GetxController {
  void confirmNewBatch(String batchDirPath, List<String> images) async {
    GalleryWriter.createDirectory(batchDirPath);
    await GalleryWriter.appendImages(
      images,
      batchDirPath,
    );

    var batch = Batch(
      title: path_lib.basename(batchDirPath),
      dirPath: batchDirPath,
    );

    Globals.batches.insert(0, batch);

    Get.offAll(
      () => ViewBatchScreen(batch),
      predicate: (route) => route.isFirst,
    );
  }

  void confirmExistingBatch(String batchDirPath, List<String> images) async {
    await GalleryWriter.appendImages(images, batchDirPath);

    final batch =
        Globals.batches.firstWhere((batch) => batch.dirPath == batchDirPath);

    Get.offAll(
      () => ViewBatchScreen(batch),
      predicate: (route) => route.isFirst,
    );
  }
}
