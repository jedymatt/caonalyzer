import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onTapFinishCapturing: (images) {},
      ),
    );
  }
}
