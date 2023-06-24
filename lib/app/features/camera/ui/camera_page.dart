import 'dart:io';

import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/ui/components/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    this.existingBatchPath,
    this.mode = CameraCaptureMode.batch,
  });

  final String? existingBatchPath;
  final CameraCaptureMode mode;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late final CameraBloc cameraBloc;
  DateTime? timeCaptured;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    cameraBloc = CameraBloc()..add(CameraStarted(mode: widget.mode));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    cameraBloc.add(
      state == AppLifecycleState.resumed
          ? CameraStarted(mode: widget.mode)
          : CameraStopped(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CameraBloc, CameraState>(
        bloc: cameraBloc,
        listener: (context, state) {
          if (state is CameraCaptureSuccess) {}
        },
        builder: (context, state) {
          if (state is! CameraReady) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              ScaledCameraPreview(cameraBloc.controller),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32, left: 16),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              // capture button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox.square(
                        dimension: 24,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            cameraBloc.add(CameraCaptured());
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                      (state.mode == CameraCaptureMode.batch &&
                              state.images.isNotEmpty)
                          ? Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                backgroundImage:
                                    FileImage(File(state.images.last)),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(BatchConfirmationPage.route(
                                      batchPath: state.batchPath!,
                                      images: state.images,
                                    ));
                                  },
                                  icon: const Icon(Icons.check),
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : const SizedBox.square(
                              dimension: 24,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
