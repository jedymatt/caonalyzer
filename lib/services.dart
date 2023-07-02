import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  final hiveDetectedObject = await Hive.openBox('detected_objects');
  getIt.registerLazySingleton<DetectedObjectService>(
    () => DetectedObjectService(hiveDetectedObject),
  );
}
