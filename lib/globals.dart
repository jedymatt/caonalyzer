import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';
const String kSettingsBoxName = 'settings';

abstract final class Globals {
  static late final List<CameraDescription> cameras;
  static late final List<String> labels;

  static Future<void> init() async {
    cameras = await availableCameras();
    labels = (await rootBundle.loadString('assets/labels.txt')).split('\n');
  }
}
