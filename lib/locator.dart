import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final locator = GetIt.instance;

void setupLocator() async {
  await Hive.openBox('detected_objects');

  locator.registerLazySingleton<DetectedObjectService>(
    () => DetectedObjectService(Hive.box('detected_objects')),
  );

  locator.registerLazySingleton<PytorchObjectDetector>(
      () => PytorchObjectDetector());

  locator.registerLazySingleton<TfServingObjectDetector>(
      () => TfServingObjectDetector());
}
