import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'batch_confirmation_screen.dart';

class BatchCameraScreen extends StatefulWidget {
  const BatchCameraScreen(this.batchPath, {super.key});

  final String batchPath;

  @override
  State<BatchCameraScreen> createState() => _BatchCameraScreenState();
}

class _BatchCameraScreenState extends State<BatchCameraScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onTapFinishCapturing: (images) {
          Get.to(
            () => BatchConfirmationScreen(
              widget.batchPath,
              images,
              existingBatch: true,
            ),
          );
        },
      ),
    );
  }
}
