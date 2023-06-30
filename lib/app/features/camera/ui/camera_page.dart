import 'dart:io';

import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/image/ui/bounding_box_painter.dart';
import 'package:caonalyzer/app/global_widgets/scaled_camera_preview.dart';
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
  late final BatchConfirmationBloc batchConfirmationBloc;
  String? batchPath;

  @override
  void initState() {
    super.initState();

    cameraBloc = CameraBloc(mode: widget.mode)
      ..add(CameraStarted(mode: widget.mode));
    batchConfirmationBloc = BlocProvider.of<BatchConfirmationBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    cameraBloc.close();
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
    return BlocListener<BatchConfirmationBloc, BatchConfirmationState>(
      listener: (context, state) {
        if (state is BatchConfirmationInitial) {
          if (state.batchPath == null) {
            batchConfirmationBloc.add(BatchConfirmationStarted(
              batchPath: batchPath,
            ));
          }
        }
      },
      child: Scaffold(
        body: BlocConsumer<CameraBloc, CameraState>(
          bloc: cameraBloc,
          listenWhen: (previous, current) => current is CameraActionState,
          listener: (context, state) {
            if (state is CameraCaptureSuccess) {
              if (state.mode == CameraCaptureMode.batch) {
                batchConfirmationBloc
                    .add(BatchConfirmationImageAdded(imagePath: state.path));
              }

              if (state.mode == CameraCaptureMode.single) {
                batchConfirmationBloc
                    .add(BatchConfirmationImageRetaked(imagePath: state.path));

                Navigator.of(context).pop();
              }
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
                CustomPaint(
                  foregroundPainter: state.detectionEnabled
                      ? BoundingBoxPainter(state.detectedObjects ?? [])
                      : null,
                  child: ScaledCameraPreview(cameraBloc.controller),
                ),
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
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, right: 16),
                      child: IconButton(
                        onPressed: () {
                          cameraBloc.add(CameraDetectionToggled());
                        },
                        icon: Icon(state.detectionEnabled
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: !state.detectionEnabled
                          ? [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox.square(
                                    dimension: 24,
                                  ),
                                  // capture button disabled when detection is enabled

                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      onPressed: state.detectionEnabled
                                          ? null
                                          : () =>
                                              cameraBloc.add(CameraCaptured()),
                                      icon: Icon(state.detectionEnabled
                                          ? Icons.disabled_by_default
                                          : Icons.camera_alt),
                                    ),
                                  ),
                                  if (state.mode == CameraCaptureMode.batch)
                                    BlocBuilder<BatchConfirmationBloc,
                                            BatchConfirmationState>(
                                        bloc: BlocProvider.of<
                                            BatchConfirmationBloc>(context),
                                        builder: (context, state) {
                                          if (state
                                                  is! BatchConfirmationInitial ||
                                              state.images.isEmpty) {
                                            return const SizedBox.square(
                                                dimension: 24);
                                          }

                                          return Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: CircleAvatar(
                                              backgroundImage: FileImage(
                                                  File(state.images.last)),
                                              child: IconButton(
                                                onPressed: () async {
                                                  cameraBloc
                                                      .add(CameraStopped());
                                                  final batchConfirmationBloc =
                                                      BlocProvider.of<
                                                              BatchConfirmationBloc>(
                                                          context);

                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider.value(
                                                      value:
                                                          batchConfirmationBloc,
                                                      child: BlocProvider.value(
                                                        value: cameraBloc,
                                                        child:
                                                            const BatchConfirmationPage(),
                                                      ),
                                                    ),
                                                  ))
                                                      .then((_) {
                                                    cameraBloc.add(
                                                        CameraStarted(
                                                            mode: widget.mode));
                                                  });
                                                },
                                                icon: const Icon(Icons.check),
                                                color: Colors.green,
                                              ),
                                            ),
                                          );
                                        }),
                                  if (state.mode == CameraCaptureMode.single)
                                    const SizedBox.square(dimension: 24),
                                ],
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
                if (state.detectionEnabled)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // display number of moldy
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '${state.detectedObjects?.length ?? 0} moldy',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        // toggle pause/resume detection
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            onPressed: () {
                              cameraBloc.add(CameraDetectionPauseToggled());
                            },
                            icon: Icon(state.detectionPaused
                                ? Icons.play_arrow
                                : Icons.pause),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
