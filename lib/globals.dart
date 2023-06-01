import 'package:caonalyzer/object_detectors/enums/preferred_mode.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

const String kAppName = 'Cao-nalyzer';

RxList<CameraDescription> cameras = <CameraDescription>[].obs;
RxString host = '192.168.1.8'.obs;
RxObjectMixin<PreferredMode> preferredMode = PreferredMode.online.obs;
