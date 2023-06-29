import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:hive/hive.dart';

abstract class ObjectDetectorConfig {
  static const kBoxName = 'object_detector';
  static late final Box _box;
  static const _modeKey = 'preferredMode';
  static const _ipAddressKey = 'ipAddress';
  static late PreferredMode mode;
  static late String ipAddress;

  static Future<void> init() async {
    _box = await Hive.openBox(kBoxName);

    mode = _box.get(
      _modeKey,
      defaultValue: PreferredMode.offline,
    );

    ipAddress = _box.get(_ipAddressKey, defaultValue: '192.168.1.8:8501');
  }

  static void save() {
    _box.put(_modeKey, mode);
    _box.put(_ipAddressKey, ipAddress);
  }

  static String get serverUrl =>
      'http://$ipAddress/v1/models/faster_rcnn:predict';
}
