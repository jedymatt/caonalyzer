import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/models/detected_object.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
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
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
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
                      cameraBloc.add(CameraDetectionToggled());
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

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraBloc.controller.value.aspectRatio,
          child: CameraPreview(cameraBloc.controller),
        ),
        BlocBuilder<CameraBloc, CameraState>(
          bloc: cameraBloc,
          buildWhen: (previous, current) =>
              previous is CameraDetectionReady &&
              current is CameraDetectionReady &&
              current.detectedObjects != previous.detectedObjects,
          builder: (context, state) {
            if (state is! CameraDetectionReady) return const SizedBox.shrink();

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
                  child: BlocBuilder<CameraBloc, CameraState>(
                    bloc: cameraBloc,
                    buildWhen: (previous, current) =>
                        previous is CameraDetectionReady &&
                        current is CameraDetectionReady &&
                        current.detectedObjects.length !=
                            previous.detectedObjects.length,
                    builder: (context, state) {
                      if (state is! CameraDetectionReady) {
                        return const SizedBox();
                      }

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
                  onPressed: () {
                    cameraBloc.add(CameraDetectionToggled());
                  },
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

  List<Widget> displayBoxesAroundRecognizedObjects(
      Size screen, List<DetectedObject> results, CameraImage? cameraImage) {
    if (results.isEmpty) return [];

    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = Colors.white;

    return results.map((result) {
      final box = result.absoluteBox(
        cameraImage?.height.toDouble() ?? 1.0,
        cameraImage?.width.toDouble() ?? 1.0,
      );

      return Positioned(
        left: box[0] * factorX,
        top: box[1] * factorY,
        width: (box[2] - box[0]) * factorX,
        height: (box[3] - box[1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2.0),
          ),
          child: Text(
            result.displayLabel,
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.red,
              fontSize: 14.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
