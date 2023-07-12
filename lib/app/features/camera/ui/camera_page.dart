import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/camera/ui/action_bars.dart';
import 'package:caonalyzer/app/features/camera/ui/buttons.dart';
import 'package:caonalyzer/app/features/camera/ui/camera_mode_selector.dart';
import 'package:caonalyzer/app/features/camera_permission/bloc/camera_permission_bloc.dart';
import 'package:caonalyzer/app/features/detector/bloc/detector_bloc.dart';
import 'package:caonalyzer/app/global_widgets/bounding_box_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

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
  late final CameraPermissionBloc cameraPermissionBloc;
  late final BatchConfirmationBloc batchConfirmationBloc;
  late final DetectorBloc detectorBloc;
  String? batchPath;
  DateTime? lastTimeDetected;

  @override
  void initState() {
    super.initState();

    cameraBloc = CameraBloc(mode: widget.mode);
    cameraPermissionBloc = CameraPermissionBloc()
      ..add(CameraPermissionRequested());
    batchConfirmationBloc = BlocProvider.of<BatchConfirmationBloc>(context);
    detectorBloc = DetectorBloc();
  }

  @override
  void dispose() {
    super.dispose();
    cameraBloc.close();
    cameraPermissionBloc.close();
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
    return MultiBlocListener(
      listeners: [
        BlocListener<BatchConfirmationBloc, BatchConfirmationState>(
          bloc: batchConfirmationBloc,
          listenWhen: (previous, current) =>
              current is BatchConfirmationInitial,
          listener: (context, state) {
            if (state is BatchConfirmationInitial) {
              if (state.batchPath == null) {
                batchConfirmationBloc.add(BatchConfirmationStarted(
                  batchPath: batchPath,
                ));
              }
            }
          },
        ),
        BlocListener<DetectorBloc, DetectorState>(
          bloc: detectorBloc,
          listenWhen: (previous, current) =>
              current is DetectorSuccess || current is DetectorFailure,
          listener: (context, state) {
            if (state is DetectorSuccess && state.detectedObjects.isNotEmpty) {
              lastTimeDetected = DateTime.now();
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
        ),
        BlocListener<CameraPermissionBloc, CameraPermissionState>(
          bloc: cameraPermissionBloc,
          listener: (context, state) {
            if (state is CameraPermissionGranted) {
              cameraBloc.add(CameraStarted(mode: widget.mode));
            }

            if (state is CameraPermissionDenied) {
              openAppSettings();
            }

            if (state is CameraPermissionPermanentlyDenied) {
              // snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera permission permanently denied'),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.of(context).pop();
            }
          },
        )
      ],
      child: Scaffold(
        body: BlocConsumer<CameraBloc, CameraState>(
          bloc: cameraBloc,
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

            if (state is CameraReady) {
              if (state.displayMode == CameraDisplayMode.analysis) {
                if (state.displayPaused) {
                  await cameraBloc.controller.stopImageStream();
                } else {
                  await cameraBloc.controller.startImageStream(
                    (image) => detectorBloc.add(DetectorStarted(
                      image: image,
                    )),
                  );
                }
              }

              if (state.displayMode == CameraDisplayMode.photo) {
                if (cameraBloc.controller.value.isStreamingImages) {
                  await cameraBloc.controller.stopImageStream();
                }
              }
            }
          },
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is CameraReady &&
                  current is CameraReady &&
                  previous.displayMode != current.displayMode),
          builder: (context, state) {
            if (state is CameraInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is CameraStopped) {
              return const Center(
                child: Text('camera stopped'),
              );
            }

            return _buildBody();
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraBloc.controller.value.aspectRatio,
          child: CameraPreview(cameraBloc.controller),
        ),
        // show bounding box
        BlocBuilder<CameraBloc, CameraState>(
          bloc: cameraBloc,
          buildWhen: (previous, current) =>
              current is CameraReady &&
              previous is CameraReady &&
              (current.displayMode != previous.displayMode),
          builder: (context, state) {
            final state_ = state as CameraReady;

            if (state_.displayMode == CameraDisplayMode.photo) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<DetectorBloc, DetectorState>(
              bloc: detectorBloc,
              buildWhen: (previous, current) {
                if (current.detectedObjects.isNotEmpty) {
                  return true;
                }
                // only show empty detection when there is no detection for the last 2 seconds
                if (lastTimeDetected == null) {
                  return false;
                }

                return DateTime.now().difference(lastTimeDetected!) >
                    const Duration(seconds: 1);
              },
              builder: (context, state) {
                return AspectRatio(
                  aspectRatio: cameraBloc.controller.value.aspectRatio,
                  child: CustomPaint(
                    foregroundPainter:
                        BoundingBoxPainter(state.detectedObjects),
                  ),
                );
              },
            );
          },
        ),
        // top action bar
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<CameraBloc, CameraState>(
              bloc: cameraBloc,
              builder: (context, state) {
                if (state is! CameraReady) return Container();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (state.displayMode == CameraDisplayMode.analysis)
                      BlocBuilder<DetectorBloc, DetectorState>(
                        bloc: detectorBloc,
                        buildWhen: (previous, current) {
                          if (current.detectedObjects.isNotEmpty) {
                            return true;
                          }
                          // only show empty detection when there is no detection for the last 2 seconds
                          if (lastTimeDetected == null) {
                            return false;
                          }

                          return DateTime.now().difference(lastTimeDetected!) >
                              const Duration(seconds: 1);
                        },
                        builder: (context, state) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              '${state.detectedObjects.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        // bottom action bar
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CameraModePage(
                  availableModes: const [
                    CameraDisplayMode.photo,
                    CameraDisplayMode.analysis
                  ],
                  onChangeCameraMode: (displayMode) {
                    cameraBloc.add(CameraDisplayModeChanged(displayMode));
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<CameraBloc, CameraState>(
                  bloc: cameraBloc,
                  buildWhen: (previous, current) =>
                      current is! CameraCaptureInProgress,
                  builder: (context, state) {
                    if (state is! CameraReady) return Container();

                    if (state.displayMode == CameraDisplayMode.photo) {
                      return BottomActionBar(
                        center: CenterButton(
                          onPressed: () {
                            cameraBloc.add(CameraCaptured());
                          },
                          child: const Icon(Icons.camera_alt),
                        ),
                        // media button display the last image captured from the batch confirmation
                        right: state.captureMode == CameraCaptureMode.batch
                            ? BlocBuilder<BatchConfirmationBloc,
                                BatchConfirmationState>(
                                bloc: batchConfirmationBloc,
                                buildWhen: (previous, current) =>
                                    current is! BatchConfirmationInitial ||
                                    current.images.isNotEmpty,
                                builder: (context, state) {
                                  if (state is! BatchConfirmationInitial ||
                                      state.images.isEmpty) {
                                    return Container();
                                  }

                                  return SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Material(
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          cameraBloc.add(CameraStopped());

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
                                        borderRadius: BorderRadius.circular(12),
                                        child: Ink.image(
                                          image: FileImage(
                                              File(state.images.last)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : null,
                      );
                    }

                    // analysis mode
                    return BottomActionBar(
                      center: CenterButton(
                        onPressed: () {
                          cameraBloc.add(CameraDetectionPauseToggled());
                        },
                        child: Icon(state.displayPaused
                            ? Icons.play_arrow
                            : Icons.pause),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
