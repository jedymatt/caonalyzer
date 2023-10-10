import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final locator = GetIt.instance;

void setupLocator() async {
  locator.registerSingletonAsync<DetectedObjectService>(
    () async => DetectedObjectService(await Hive.openBox(
      'detected_objects',
    )),
  );
}
