import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:hive/hive.dart';

class ObjectDetectorSettings {
  late final Box _box;

  ObjectDetectorSettings(Box box) {
    _box = box;

    preferredMode = PreferredMode.values[_box.get(
      'preferredMode',
      defaultValue: 0,
    )];

    serverHost = _box.get('serverHost', defaultValue: '192.168.1.8:8501');
  }

  PreferredMode preferredMode = PreferredMode.offline;
  String serverHost = '192.168.1.8:8501';

  String get serverUrl => 'http://$serverHost/v1/models/faster_rcnn:predict';

  void save() {
    _box.put('preferredMode', preferredMode.index);
    _box.put('serverHost', serverHost);
  }

  Box get box => _box;
}
