import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/detector/bloc/detector_bloc.dart';
import 'package:caonalyzer/app/features/image/ui/bounding_box_painter.dart';
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
  late final DetectorBloc detectorBloc;
  String? batchPath;

  @override
  void initState() {
    super.initState();

    cameraBloc = CameraBloc(mode: widget.mode)
      ..add(CameraStarted(mode: widget.mode));
    batchConfirmationBloc = BlocProvider.of<BatchConfirmationBloc>(context);
    detectorBloc = DetectorBloc();
  }

  @override
  void dispose() {
    super.dispose();
    cameraBloc.close();
    detectorBloc.close();
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
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: (context, state) async {
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

            if (state is CameraDetectionReady) {
              if (state.paused) {
                await cameraBloc.controller.stopImageStream();
              } else {
                await cameraBloc.controller.startImageStream(
                  (image) => detectorBloc.add(DetectorStarted(
                    image: image,
                  )),
                );
              }
            }

            if (state is CameraReady) {
              if (cameraBloc.controller.value.isStreamingImages) {
                await cameraBloc.controller.stopImageStream();
              }
            }
          },
          builder: (context, state) {
            if (state is CameraStopped) {
              return const Center(
                child: Text('camera stopped'),
              );
            }

            if (state is CameraReady) {
              return _buildCameraReady(state, context);
            }

            if (state is CameraDetectionReady) {
              return _buildCameraDetectionReady();
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCameraReady(CameraReady state, BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraBloc.controller.value.aspectRatio,
          child: CameraPreview(cameraBloc.controller),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      cameraBloc.add(CameraDetectionStarted());
                    },
                    icon: const Icon(Icons.visibility_off),
                  ),
                ],
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        onPressed: () => cameraBloc.add(CameraCaptured()),
                        icon: const Icon(Icons.camera_alt),
                      ),
                    ),
                    if (state.mode == CameraCaptureMode.batch)
                      BlocBuilder<BatchConfirmationBloc,
                              BatchConfirmationState>(
                          bloc: BlocProvider.of<BatchConfirmationBloc>(context),
                          builder: (context, state) {
                            if (state is! BatchConfirmationInitial ||
                                state.images.isEmpty) {
                              return const SizedBox.square(dimension: 24);
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
                                        BlocProvider.of<BatchConfirmationBloc>(
                                            context);

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: batchConfirmationBloc,
                                        child: BlocProvider.value(
                                          value: cameraBloc,
                                          child: const BatchConfirmationPage(),
                                        ),
                                      ),
                                    ))
                                        .then((_) {
                                      cameraBloc.add(
                                          CameraStarted(mode: widget.mode));
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraDetectionReady() {
    print('>>>>>>>> rebuild: _buildCameraDetectionReady');
    // only show empty detection when there is no detection for the last 2 seconds
    DateTime? lastDetectionTime;

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraBloc.controller.value.aspectRatio,
          child: CameraPreview(cameraBloc.controller),
        ),
        BlocConsumer<DetectorBloc, DetectorState>(
          bloc: detectorBloc,
          listener: (context, state) {
            if (state is DetectorSuccess && state.detectedObjects.isNotEmpty) {
              lastDetectionTime = DateTime.now();
            }

            if (state is DetectorFailure) {
              // snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  onVisible: () {
                    Future.delayed(const Duration(seconds: 2), () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    });
                  },
                ),
              );
            }
          },
          buildWhen: (previous, current) {
            if (current.detectedObjects.isNotEmpty) {
              return true;
            }
            // only show empty detection when there is no detection for the last 2 seconds
            if (lastDetectionTime == null) {
              return false;
            }

            return DateTime.now().difference(lastDetectionTime!) >
                const Duration(seconds: 1);
          },
          builder: (context, state) {
            return AspectRatio(
              aspectRatio: cameraBloc.controller.value.aspectRatio,
              child: CustomPaint(
                foregroundPainter: BoundingBoxPainter(state.detectedObjects),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
                // count of detected objects
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: BlocBuilder<DetectorBloc, DetectorState>(
                    bloc: detectorBloc,
                    buildWhen: (previous, current) {
                      if (current.detectedObjects.isNotEmpty) {
                        return true;
                      }
                      // only show empty detection when there is no detection for the last 2 seconds
                      if (lastDetectionTime == null) {
                        return false;
                      }

                      return DateTime.now().difference(lastDetectionTime!) >
                          const Duration(seconds: 1);
                    },
                    builder: (context, state) {
                      return Text(
                        '${state.detectedObjects.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          // fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async =>
                      cameraBloc.add(CameraDetectionStopped()),
                  icon: const Icon(Icons.visibility),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: BlocBuilder<CameraBloc, CameraState>(
                    bloc: cameraBloc,
                    buildWhen: (previous, current) =>
                        previous is CameraDetectionReady &&
                        current is CameraDetectionReady &&
                        current.paused != previous.paused,
                    builder: (context, state) {
                      if (state is! CameraDetectionReady) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        onPressed: () =>
                            cameraBloc.add(CameraDetectionPauseToggled()),
                        icon:
                            Icon(state.paused ? Icons.play_arrow : Icons.pause),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
