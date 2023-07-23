import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_confirmation/ui/batch_confirmation_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/camera/ui/action_bars.dart';
import 'package:caonalyzer/app/features/camera/ui/buttons.dart';
import 'package:caonalyzer/app/features/camera/ui/camera_mode_selector.dart';
import 'package:caonalyzer/app/features/camera_permission/bloc/camera_permission_bloc.dart';
import 'package:caonalyzer/app/features/camera_detector/bloc/camera_detector_bloc.dart';
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
  late final CameraDetectorBloc detectorBloc;
  String? batchPath;
  DateTime? lastTimeDetected;

  @override
  void initState() {
    super.initState();

    cameraBloc = CameraBloc(mode: widget.mode);
    cameraPermissionBloc = CameraPermissionBloc()
      ..add(CameraPermissionRequested());
    batchConfirmationBloc = BlocProvider.of<BatchConfirmationBloc>(context);
    detectorBloc = CameraDetectorBloc();
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
        BlocListener<CameraDetectorBloc, CameraDetectorState>(
          bloc: detectorBloc,
          listenWhen: (previous, current) =>
              current is CameraDetectorSuccess ||
              current is CameraDetectorFailure,
          listener: (context, state) {
            if (state is CameraDetectorSuccess &&
                state.detectedObjects.isNotEmpty) {
              lastTimeDetected = DateTime.now();
            }

            if (state is CameraDetectorFailure) {
              // snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              cameraBloc.controller.stopImageStream();
            }
          },
        ),
        BlocListener<CameraPermissionBloc, CameraPermissionState>(
          bloc: cameraPermissionBloc,
          listener: (context, state) {
            if (state is CameraPermissionGranted) {
              cameraBloc.add(CameraStarted(mode: widget.mode));
            }

            if (state is CameraPermissionDenied ||
                state is CameraPermissionPermanentlyDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Camera permission denied.'
                    ' Please try again or enable it in the app settings.',
                  ),
                  action: SnackBarAction(
                    label: 'Settings',
                    onPressed: openAppSettings,
                  ),
                ),
              );
              Navigator.of(context).pop();
            }
          },
        ),
        BlocListener<CameraBloc, CameraState>(
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
                  if (!cameraBloc.controller.value.isStreamingImages) {
                    await cameraBloc.controller.startImageStream(
                      (image) => detectorBloc.add(CameraDetectorStarted(
                        image: image,
                      )),
                    );
                  }
                }
              }

              if (state.displayMode == CameraDisplayMode.photo) {
                if (cameraBloc.controller.value.isStreamingImages) {
                  await cameraBloc.controller.stopImageStream();
                }
              }
            }
          },
        )
      ],
      child: Scaffold(
        body: BlocBuilder<CameraBloc, CameraState>(
          bloc: cameraBloc,
          buildWhen: (previous, current) {
            if (current is CameraCaptureInProgress ||
                current is CameraCaptureSuccess ||
                current is CameraCaptureFailure) {
              return false;
            }

            return true;
          },
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

            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CameraState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraBloc.controller.value.aspectRatio,
          child: CameraPreview(cameraBloc.controller),
        ),
        // show bounding box
        if (state is CameraReady &&
            state.displayMode == CameraDisplayMode.analysis)
          _buildAnalysisBoundingBox(),
        // top action bar
        if (state is CameraReady &&
            state.displayMode == CameraDisplayMode.analysis)
          _buildAnalysisTopActionBar(),
        // bottom action bar
        if (state is CameraReady &&
            state.displayMode == CameraDisplayMode.photo)
          _buildPhotoTopActionBar(),

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
                _buildDisplayModePageOptions(),
                const SizedBox(height: 16),
                if (state is CameraReady &&
                    state.displayMode == CameraDisplayMode.photo)
                  _buildPhotoBottomActionBar(state),
                if (state is CameraReady &&
                    state.displayMode == CameraDisplayMode.analysis)
                  _buildAnalysisBottomActionBar(state)
              ],
            ),
          ),
        ),
      ],
    );
  }

  CameraModePage _buildDisplayModePageOptions() {
    return CameraModePage(
      availableModes: const [
        CameraDisplayMode.photo,
        CameraDisplayMode.analysis
      ],
      onChangeCameraMode: (displayMode) {
        cameraBloc.add(CameraDisplayModeChanged(displayMode));
      },
    );
  }

  BottomActionBar _buildPhotoBottomActionBar(CameraReady state) {
    return BottomActionBar(
      center: BlocBuilder<CameraBloc, CameraState>(
        bloc: cameraBloc,
        builder: (context, state) {
          return CaptureButton(
            onPressed: () => cameraBloc.add(CameraCaptured()),
            disabled: state is CameraCaptureInProgress,
          );
        },
      ),
      // media button display the last image captured from the batch confirmation
      right: state.captureMode == CameraCaptureMode.batch
          ? BlocBuilder<BatchConfirmationBloc, BatchConfirmationState>(
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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        cameraBloc.add(CameraStopped());

                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: batchConfirmationBloc,
                            child: BlocProvider.value(
                              value: cameraBloc,
                              child: const BatchConfirmationPage(),
                            ),
                          ),
                        ));

                        cameraBloc.add(CameraStarted(mode: widget.mode));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink.image(
                        image: FileImage(File(state.images.last)),
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

  BottomActionBar _buildAnalysisBottomActionBar(CameraReady state) {
    return BottomActionBar(
      center: CenterButton(
        onPressed: () {
          cameraBloc.add(CameraDetectionPauseToggled());
        },
        child: Icon(
          state.displayPaused ? Icons.play_arrow : Icons.pause,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAnalysisTopActionBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: BlocBuilder<CameraDetectorBloc, CameraDetectorState>(
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
                          color: Colors.red.withOpacity(0.5),
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
                ),
                // flash torch/off
                Align(
                  alignment: Alignment.centerRight,
                  child: Builder(
                    builder: (context) {
                      final state = cameraBloc.state as CameraReady;

                      IconData iconData = Icons.flash_auto;

                      switch (state.flashMode) {
                        case CameraFlashMode.torch:
                          iconData = Icons.flashlight_on;
                        case CameraFlashMode.off:
                          iconData = Icons.flashlight_off;
                          break;
                        default:
                          iconData = Icons.flashlight_off;
                      }

                      return IconButton(
                        onPressed: () {
                          switch (state.flashMode) {
                            case CameraFlashMode.off:
                              cameraBloc.add(CameraFlashModeChanged(
                                  CameraFlashMode.torch));
                              break;
                            case CameraFlashMode.torch:
                              cameraBloc.add(
                                  CameraFlashModeChanged(CameraFlashMode.off));
                            default:
                              cameraBloc.add(CameraFlashModeChanged(
                                  CameraFlashMode.torch));
                          }
                        },
                        icon: Icon(
                          iconData,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisBoundingBox() {
    return BlocBuilder<CameraDetectorBloc, CameraDetectorState>(
      bloc: detectorBloc,
      buildWhen: (previous, current) {
        if (current is CameraDetectorInProgress) {
          return false;
        }

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
            foregroundPainter: BoundingBoxPainter(state.detectedObjects),
          ),
        );
      },
    );
  }

  Widget _buildPhotoTopActionBar() {
    final state = cameraBloc.state as CameraReady;

    IconData iconData = Icons.flash_auto;

    switch (state.flashMode) {
      case CameraFlashMode.auto:
        iconData = Icons.flash_auto;
        break;
      case CameraFlashMode.on:
        iconData = Icons.flash_on;
        break;
      case CameraFlashMode.off:
        iconData = Icons.flash_off;
        break;
      case CameraFlashMode.torch:
        iconData = Icons.flashlight_on;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              switch (state.flashMode) {
                case CameraFlashMode.auto:
                  cameraBloc.add(CameraFlashModeChanged(CameraFlashMode.on));
                  break;
                case CameraFlashMode.on:
                  cameraBloc.add(CameraFlashModeChanged(CameraFlashMode.off));
                  break;
                case CameraFlashMode.off:
                  cameraBloc.add(CameraFlashModeChanged(CameraFlashMode.torch));
                  break;
                case CameraFlashMode.torch:
                  cameraBloc.add(CameraFlashModeChanged(CameraFlashMode.auto));
              }
            },
            icon: Icon(
              iconData,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
