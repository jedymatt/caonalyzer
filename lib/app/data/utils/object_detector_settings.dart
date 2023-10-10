import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:hive/hive.dart';

class ObjectDetectorSettings {
  late final Box _box;

  ObjectDetectorSettings(Box box) {
    _box = box;
  }

  PreferredMode preferredMode = PreferredMode.offline;

  Box get box => _box;
}
