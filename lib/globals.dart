import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';
const String kSettingsBoxName = 'settings';

abstract final class Globals {
  static late final List<CameraDescription> cameras;
  static final host = '192.168.1.8'.obs;
  static final port = '8000'.obs;
  static final labels = <String>[].obs;

  static Future<void> init() async {
    cameras = await availableCameras();
    labels.value =
        (await rootBundle.loadString('assets/labels.txt')).split('\n');
  }
}
