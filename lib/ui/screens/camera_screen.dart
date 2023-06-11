import 'dart:io';

import 'package:camera/camera.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'camera/batch_confirmation_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.batchPath});

  final String? batchPath;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController cameraController;
  late RealtimeObjectDetector objectDetector;
  CameraImage? _cameraImage;
  List<ObjectDetectionOutput> outputs = [];
  int iteration = 0;
  List<String> images = [];

  @override
  void initState() {
    super.initState();

    objectDetector = preferredMode.value.realtimeObjectDetector;

    _initializeCameraController(cameras[0]);
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: CameraPreview(cameraController),
          ),
          ...detectedObjects(MediaQuery.of(context).size),
          Positioned(
              left: 0,
              right: 0,
              bottom: kToolbarHeight,
              // circle button (capture button)
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          // shape: const CircleBorder(),
                          child: InkWell(
                            onTap: captureImage,
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
                              clipBehavior: Clip.antiAlias,
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
                    ),
                    // redirect to batch confirmation screen
                    if (images.isNotEmpty)
                      Align(
                          alignment: Alignment.centerRight,
                          child: Material(
                            child: SizedBox.square(
                              dimension: 80,
                              child: InkWell(
                                onTap: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        BatchConfirmationScreen(images),
                                  ));
                                },
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(images.last),
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    // check icon
                                    const Expanded(
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void captureImage() async {
    if (cameraController.value.isStreamingImages) {
      cameraController.stopImageStream();
    }

    XFile file = await cameraController.takePicture();

    debugPrint('Image captured: ${file.path}');

    // final batchPath =
    //     widget.batchPath ?? GalleryWriter.instance.generateBatchPath();
    //
    // if (widget.batchPath == null) {
    //   GalleryWriter.instance.createDirectory(batchPath);
    // }
    //
    // String path =
    //     await GalleryWriter.instance.appendImage(file.path, batchPath);

    setState(() {
      images.add(file.path);
    });
  }

  void _initializeCameraController(CameraDescription description) async {
    cameraController = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
    );

    cameraController.initialize().then((_) {
      if (cameraController.value.isStreamingImages) {
        return;
      }

      setState(() {
        cameraController.startImageStream((image) {
          _cameraImage = image;
          _imageStream(image);
        });
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

  void _imageStream(CameraImage image) async {
    objectDetector
        .runInferenceOnFrame(
      image.planes.map((plane) => plane.bytes).toList(),
      image.height,
      image.width,
    )
        .then((value) {
      if (value.isNotEmpty) {
        setState(() {
          outputs = value;
        });
      }

      if (value.isEmpty && iteration > 500) {
        setState(() {
          outputs = [];
        });

        iteration = 0;
      }

      iteration++;
    });
  }

  List<Widget> detectedObjects(Size screen) {
    if (outputs.isEmpty) return [];

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    double factorX = screen.width / (_cameraImage?.height ?? 1);
    double factorY = screen.height / (_cameraImage?.width ?? 1);

    return outputs.map((result) {
      return Positioned(
        left: result.boundingBox.left * factorX,
        top: result.boundingBox.top * factorY,
        width: (result.boundingBox.right - result.boundingBox.left) * factorX,
        height: (result.boundingBox.bottom - result.boundingBox.top) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result.label} ${(result.confidence * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
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
