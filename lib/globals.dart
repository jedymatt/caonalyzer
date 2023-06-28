import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';
const String kSettingsBoxName = 'settings';

final box = GetStorage();

Future<void> initGlobals() async {}

abstract final class Globals {
  static final preferredMode = PreferredMode.offline.obs;
  static final cameras = <CameraDescription>[].obs;
  static final host = '192.168.1.8'.obs;
  static final port = '8000'.obs;
  static final labels = <String>[].obs;

  static Future<void> init() async {
    cameras.value = await availableCameras();
    labels.value =
        (await rootBundle.loadString('assets/labels.txt')).split('\n');
  }
}
