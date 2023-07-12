part of 'camera_permission_bloc.dart';

@immutable
abstract class CameraPermissionState {}

class CameraPermissionInitial extends CameraPermissionState {}

class CameraPermissionRequestInProgress extends CameraPermissionState {}

class CameraPermissionDenied extends CameraPermissionState {}

class CameraPermissionGranted extends CameraPermissionState {}

class CameraPermissionPermanentlyDenied extends CameraPermissionState {}
