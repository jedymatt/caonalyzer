import 'package:get/get.dart';
import 'package:camera/camera.dart';

const String kAppName = 'Cao-nalyzer';

List<CameraDescription> cameras = Get.put([], permanent: true);
String host = Get.put('192.168.1.4', permanent: true);
