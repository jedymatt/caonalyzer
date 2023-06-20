import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:caonalyzer/ui/screens/batch_confirmation_screen.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  DateTime? timeCaptured;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onTapCaptureImage: (image) {
          timeCaptured ??= DateTime.now();
        },
        onTapFinishCapturing: (images) async {
          final batchPath =
              await GalleryWriter.generateBatchPath(timeCaptured!);

          if (!mounted) return;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BatchConfirmationScreen(
              batchPath,
              images,
            ),
          ));
        },
      ),
    );
  }
}
