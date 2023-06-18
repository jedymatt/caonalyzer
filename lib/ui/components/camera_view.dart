import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.onTapFinishCapturing,
    this.onTapCaptureImage,
    this.streamImage,
  });

  final Function(List<String>) onTapFinishCapturing;
  final Function(File)? onTapCaptureImage;
  final Function(CameraImage)? streamImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController cameraController;
  late String batchPath;
  List<String> images = [];
  bool isTakingPicture = false;

  @override
  void initState() {
    super.initState();

    _initializeCameraController(Globals.cameras.first);

    cameraController.addListener(() {
      if (cameraController.value.isTakingPicture) {
        debugPrint('isTakingPicture');
        setState(() {
          isTakingPicture = true;
        });
      } else {
        debugPrint('isNotTakingPicture');
        setState(() {
          isTakingPicture = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    debugPrint('AppLifecycleState: $state');

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      debugPrint('Camera disposed');
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ScaledCameraPreview(cameraController),
        // ...detectedObjects(MediaQuery.of(context).size),
        // appbar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.white.withAlpha(100),
          ),
        ),
        buildBottomBar(context),
      ],
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // circle button (capture button)
      child: Container(
        color: Colors.white.withAlpha(100),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox.square(
              dimension: 80,
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: isTakingPicture
                  ? Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white12,
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: Colors.red,
                            width: 5,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const SizedBox(
                        height: 60,
                        width: 60,
                      ),
                    )
                  : Material(
                      child: InkWell(
                        onTap: () async {
                          if (cameraController.value.isStreamingImages) {
                            cameraController.stopImageStream();
                          }

                          XFile file = await cameraController.takePicture();

                          if (widget.onTapCaptureImage != null) {
                            widget.onTapCaptureImage!(File(file.path));
                          }

                          setState(() {
                            images.add(file.path);
                          });
                        },
                        child: Container(
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white60,
                            border: Border.fromBorderSide(
                              BorderSide(
                                color: Colors.red,
                                width: 5,
                              ),
                            ),
                          ),
                          child: const SizedBox(
                            height: 60,
                            width: 60,
                            child: Icon(
                              Icons.camera,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            // redirect to batch confirmation screen
            images.isNotEmpty
                ? SizedBox.square(
                    dimension: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => widget.onTapFinishCapturing(images),
                          child: Ink.image(
                            image: FileImage(File(images.last)),
                            fit: BoxFit.cover,
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.square(dimension: 80),
          ],
        ),
      ),
    );
  }

  void _initializeCameraController(CameraDescription description) async {
    cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    cameraController.initialize().then((_) {
      if (cameraController.value.isStreamingImages) {
        return;
      }

      setState(() {
        if (widget.streamImage != null) {
          cameraController.startImageStream((image) {
            widget.streamImage!(image);
          });
        }
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  List<Widget> detectedObjects(Size screen) {
    return [];
  }
}

class ScaledCameraPreview extends StatelessWidget {
  final CameraController cameraController;

  const ScaledCameraPreview(this.cameraController, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * cameraController.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(cameraController)),
    );
  }
}
