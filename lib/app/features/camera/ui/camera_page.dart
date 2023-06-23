import 'dart:io';

import 'package:caonalyzer/app/data/enums/capture_mode.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    this.existingBatchPath,
    this.captureMode = CaptureMode.batch,
    this.onSingleCapture,
  }) : assert(captureMode != CaptureMode.single || onSingleCapture != null);

  final String? existingBatchPath;
  final CaptureMode captureMode;
  final void Function(File image)? onSingleCapture;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  DateTime? timeCaptured;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onTapCaptureImage: widget.captureMode == CaptureMode.batch
            ? (image) => timeCaptured ??= DateTime.now()
            : widget.onSingleCapture,
        onTapFinishCapturing: widget.captureMode == CaptureMode.batch
            ? (images) async {
                final batchPath = widget.existingBatchPath ??
                    await GalleryWriter.generateBatchPath(timeCaptured!);

                if (!mounted) return;

                // get the previous route name

                Navigator.of(context).push(BatchConfirmationPage.route(
                  batchPath: batchPath,
                  images: images,
                  isFromBatchPage: widget.existingBatchPath != null,
                ));
              }
            : null,
      ),
    );
  }
}
