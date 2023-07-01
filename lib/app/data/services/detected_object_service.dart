import 'package:caonalyzer/app/data/models/models.dart';
import 'package:hive/hive.dart';

class DetectedObjectService {
  final Box _box;

  DetectedObjectService(Box box) : _box = box;

  List<DetectedObject> getAll(String imagePath) {
    return List.from(_box.get(imagePath, defaultValue: []))
        .map((e) => DetectedObject.fromJson(e))
        .toList();
  }

  void add(String imagePath, DetectedObject detectedObject) {
    _box.put(
        imagePath,
        getAll(imagePath)
          ..add(detectedObject)
          ..map((e) => e.toJson()).toList());
  }

  void putAll(String imagePath, List<DetectedObject> detectedObjects) {
    _box.put(imagePath, detectedObjects.map((e) => e.toJson()).toList());
  }
}
