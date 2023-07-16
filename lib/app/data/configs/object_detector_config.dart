import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:hive/hive.dart';

abstract class ObjectDetectorConfig {
  static const kBoxName = 'object_detector';
  static late final Box _box;
  static const _modeKey = 'preferredMode';
  static const _ipAddressKey = 'ipAddress';
  static late ConfigValue<PreferredMode> mode;
  static late ConfigValue<String> ipAddress;

  static Future<void> init() async {
    _box = await Hive.openBox(kBoxName);

    mode = ConfigValue(_box, _modeKey, defaultValue: PreferredMode.offline);

    ipAddress =
        ConfigValue(_box, _ipAddressKey, defaultValue: '192.168.1.8:8501');
  }

  static String get serverUrl =>
      'http://${ipAddress.value}/v1/models/faster_rcnn:predict';
}

class ConfigValue<T> {
  final String _key;
  final Box _box;
  T value;

  ConfigValue(Box box, String key, {T? defaultValue})
      : _box = box,
        _key = key,
        value = box.get(key, defaultValue: defaultValue);

  void save(T? newValue) {
    value = newValue ?? value;

    _box.put(_key, value);
  }
}
