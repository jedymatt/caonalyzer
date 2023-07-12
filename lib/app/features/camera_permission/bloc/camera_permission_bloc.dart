import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'camera_permission_event.dart';
part 'camera_permission_state.dart';

class CameraPermissionBloc
    extends Bloc<CameraPermissionEvent, CameraPermissionState> {
  CameraPermissionBloc() : super(CameraPermissionInitial()) {
    on<CameraPermissionRequested>(_onRequested);
  }

  FutureOr<void> _onRequested(CameraPermissionRequested event,
      Emitter<CameraPermissionState> emit) async {
    emit(CameraPermissionRequestInProgress());

    final status = await Permission.camera.request();

    if (status.isDenied) {
      emit(CameraPermissionDenied());
    } else if (status.isGranted) {
      emit(CameraPermissionGranted());
    } else if (status.isPermanentlyDenied) {
      emit(CameraPermissionPermanentlyDenied());
    }
  }
}
