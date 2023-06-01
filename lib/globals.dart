import 'package:caonalyzer/object_detectors/enums/preferred_mode.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';

final box = GetStorage();

RxList<CameraDescription> cameras = <CameraDescription>[].obs;
RxString host = '192.168.1.8'.obs;
Rx<PreferredMode> preferredMode = PreferredMode.online.obs;
RxList<String> labels = <String>[].obs;

Future<void> initGlobals() async {
  cameras.value = await availableCameras();

  labels.value = (await rootBundle.loadString('assets/labels.txt')).split('\n');
}
