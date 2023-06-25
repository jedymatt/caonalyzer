import 'dart:io';

import 'package:caonalyzer/app/data/enums/capture_mode.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
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
    required this.onCapture,
  });

  final String? existingBatchPath;
  final CameraCaptureMode mode;
  final void Function(String path) onCapture;

  static CameraPage batch({
    required void Function(String path) onCapture,
    String? existingBatchPath,
  }) =>
      CameraPage(
        mode: CameraCaptureMode.batch,
        onCapture: onCapture,
        existingBatchPath: existingBatchPath,
      );

  static CameraPage single({
    required void Function(String path) onCapture,
  }) =>
      CameraPage(
        mode: CameraCaptureMode.single,
        onCapture: onCapture,
      );

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late final CameraBloc cameraBloc;

  @override
  void initState() {
    super.initState();

    cameraBloc = BlocProvider.of<CameraBloc>(context)
      ..add(CameraStarted(mode: widget.mode));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState: ${state.toString()}');
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
        listenWhen: (previous, current) => current is CameraActionState,
        buildWhen: (previous, current) => current is! CameraActionState,
        listener: (context, state) {
          if (state is CameraCaptureSuccess) {
            widget.onCapture(state.path);
          }
        },
        builder: (context, state) {
          if (state is CameraStopped) {
            return const Center(
              child: Text('camera stopped'),
            );
          }

          if (state is! CameraReady) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              ScaledCameraPreview(state.controller),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Text('${state.mode}')),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
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
                              onPressed: () {
                                cameraBloc.add(CameraCaptured());
                              },
                              icon: const Icon(Icons.camera_alt),
                            ),
                          ),
                          if (state.mode == CameraCaptureMode.batch)
                            BlocBuilder<BatchConfirmationBloc,
                                    BatchConfirmationState>(
                                bloc: BlocProvider.of<BatchConfirmationBloc>(
                                    context),
                                builder: (context, state) {
                                  if (state is! BatchConfirmationInitial ||
                                      state.images.isEmpty) {
                                    return const SizedBox.square(
                                      dimension: 24,
                                    );
                                  }

                                  return Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          FileImage(File(state.images.last)),
                                      child: IconButton(
                                        onPressed: () async {
                                          cameraBloc.add(CameraStopped());
                                          final batchConfirmationBloc =
                                              BlocProvider.of<
                                                      BatchConfirmationBloc>(
                                                  context);

                                          await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                BlocProvider.value(
                                              value: batchConfirmationBloc,
                                              child: BlocProvider.value(
                                                value: cameraBloc,
                                                child:
                                                    const BatchConfirmationPage(),
                                              ),
                                            ),
                                          ));

                                          cameraBloc.add(
                                              CameraStarted(mode: widget.mode));
                                        },
                                        icon: const Icon(Icons.check),
                                        color: Colors.green,
                                      ),
                                    ),
                                  );
                                }),
                          if (state.mode == CameraCaptureMode.single)
                            const SizedBox.square(
                              dimension: 24,
                            ),
                        ],
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
