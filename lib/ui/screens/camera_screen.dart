import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/box_converter.dart';
import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController cameraController;
  late ObjectDetector objectDetector;
  imageLib.Image? currentImage;

  @override
  void initState() {
    super.initState();

    objectDetector = preferredMode.value.objectDetector;

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

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaledCameraPreview(cameraController),
      floatingActionButton: FloatingActionButton(
        onPressed: clickCamera,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void clickCamera() {}

  void _initializeCameraController(CameraDescription description) async {
    cameraController = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
    );

    cameraController.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        cameraController.startImageStream(_imageStream);
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

  Widget camera(context) {
    if (!cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
      child: Center(
        child: CameraPreview(
          cameraController,
          child: AppBar(),
        ),
      ),
    );
  }

  void _imageStream(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageLib.Image imageFromBytes = imageLib.Image.fromBytes(
      imageSize.width.toInt(),
      imageSize.height.toInt(),
      bytes,
      format: imageLib.Format.rgb,
    );

    final tensorImage = objectDetector.preProcessImage(imageFromBytes);

    final output = await objectDetector.runInference(tensorImage);

    final postProccessedImage = tensorImage.image.clone();

    // draw bounding boxes on image
    final boxes = BoxConverter.convert(
      output.detectionBoxes,
      height: image.height,
      width: image.width,
    );

    for (Rect box in boxes) {
      imageLib.drawRect(
        postProccessedImage,
        box.left.toInt(),
        box.top.toInt(),
        box.right.toInt(),
        box.bottom.toInt(),
        imageLib.getColor(0, 255, 0),
      );

      final label = labels[output.detectionClasses[boxes.indexOf(box)]];
      final score = output.detectionScores[boxes.indexOf(box)];

      imageLib.drawStringWrap(
        postProccessedImage,
        imageLib.arial_14,
        box.left.toInt(),
        box.top.toInt(),
        '$label ${(score * 100).toStringAsFixed(2)}%',
        color: imageLib.getColor(0, 255, 0),
      );
    }

    setState(() {
      currentImage = postProccessedImage;
    });
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
