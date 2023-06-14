import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'gallery/models/batch.dart';

const String kAppName = 'Cao-nalyzer';

final box = GetStorage();

RxList<CameraDescription> cameras = <CameraDescription>[].obs;
RxString host = '192.168.1.8'.obs;
Rx<PreferredMode> preferredMode = PreferredMode.offline.obs;
RxList<String> labels = <String>[].obs;
final batches = <Batch>[].obs;

Future<void> initGlobals() async {
  cameras.value = await availableCameras();

  labels.value = (await rootBundle.loadString('assets/labels.txt')).split('\n');
}
