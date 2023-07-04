import 'package:camera/camera.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:flutter/services.dart' show rootBundle;

const String kAppName = 'Cao-nalyzer';
const String kSettingsBoxName = 'settings';

abstract final class Globals {
  static late final List<CameraDescription> cameras;
  static late final List<String> labels;

  static Future<void> init() async {
    cameras = await AndroidCameraCameraX().availableCameras();
    labels = (await rootBundle.loadString('assets/labels.txt')).split('\n');
  }
}
