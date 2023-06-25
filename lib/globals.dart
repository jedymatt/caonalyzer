import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';

final box = GetStorage();

RxString host = '192.168.1.8'.obs;
RxList<String> labels = <String>[].obs;

Future<void> initGlobals() async {}

abstract final class Globals {
  static final preferredMode = PreferredMode.offline.obs;
  static final cameras = <CameraDescription>[].obs;

  static Future<void> init() async {
    cameras.value = await availableCameras();
    labels.value =
        (await rootBundle.loadString('assets/labels.txt')).split('\n');
  }
}
