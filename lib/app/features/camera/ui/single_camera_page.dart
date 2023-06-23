import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:flutter/material.dart';

class SingleCameraPage extends StatefulWidget {
  const SingleCameraPage({
    super.key,
    this.existingBatchPath,
    this.onCapture,
  });

  final String? existingBatchPath;
  final void Function(File image)? onCapture;

  @override
  State<SingleCameraPage> createState() => _SingleCameraPageState();
}

class _SingleCameraPageState extends State<SingleCameraPage> {
  DateTime? timeCaptured;
  late CameraController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      Globals.cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onTapCaptureImage: widget.onCapture,
        cameraController: cameraController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    cameraController.dispose();
  }
}
