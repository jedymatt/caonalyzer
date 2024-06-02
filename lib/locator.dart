import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:caonalyzer/app/data/utils/object_detector_settings.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final locator = GetIt.instance;

void setupLocator() async {
  locator.registerSingletonAsync<DetectedObjectService>(
    () async => DetectedObjectService(await Hive.openBox(
      'detected_objects',
    )),
  );

  locator.registerSingletonAsync<ObjectDetectorSettings>(
    () async => ObjectDetectorSettings(await Hive.openBox(
      'object_detector_settings',
    )),
  );
}
