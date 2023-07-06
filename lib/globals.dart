import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

const String kAppName = 'Cao-nalyzer';
const String kSettingsBoxName = 'settings';

abstract final class Globals {
  static late final List<CameraDescription> cameras;
  static late final List<String> labels;
  static late final String appVersion;
  static late final String buildNumber;

  static Future<void> init() async {
    cameras = await availableCameras();
    labels = (await rootBundle.loadString('assets/labels.txt')).split('\n');

    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
