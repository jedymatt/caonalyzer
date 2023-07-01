import 'dart:convert';

import 'package:caonalyzer/app/data/models/models.dart';
import 'package:hive/hive.dart';

class DetectedObjectService {
  final Box _box;

  DetectedObjectService(Box box) : _box = box;

  List<DetectedObject>? getAll(String imagePath) {
    final String? detectedObjects = _box.get(imagePath);

    if (detectedObjects == null) {
      return null;
    }

    return List.from(json.decode(detectedObjects))
        .map((e) => DetectedObject.fromMap(e))
        .toList();
  }

  void putAll(String imagePath, List<DetectedObject> detectedObjects) {
    _box.put(
      imagePath,
      json.encode(detectedObjects.map((e) => e.toMap()).toList()),
    );
  }
}
