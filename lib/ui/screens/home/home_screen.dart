import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/object_detection_output.dart';
import 'package:caonalyzer/object_detectors/object_detector.dart';
import 'package:caonalyzer/ui/screens/camera_screen.dart';
import 'package:caonalyzer/ui/screens/image_screen.dart';
import 'package:caonalyzer/ui/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ObjectDetector objectDetector;
  String message = '';
  bool isBusy = false;
  ObjectDetectionOutput objectDetectionOutput = ObjectDetectionOutput.empty();

  @override
  void initState() {
    super.initState();

    objectDetector = preferredMode.value.objectDetector;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(kAppName),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings),
            )
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.home),
                iconMargin: EdgeInsets.zero,
                text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.photo),
                iconMargin: EdgeInsets.zero,
                text: 'Gallery',
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Pick Image'),
              ),
              isBusy
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
              Text('Outputs count: ${objectDetectionOutput.numDetections}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToCamera,
          label: const Text('Camera'),
          icon: const Icon(Icons.camera),
        ),
      ),
    );
  }

  void navigateToCamera() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CameraScreen()));
  }

  void pickImage() async {
    final imagePicker = ImagePicker();
    XFile? fileImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (fileImage == null) return;

    final imageBytes = await fileImage.readAsBytes();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    final tensorImage = objectDetector.preProcessImage(decodedImage);

    try {
      setState(() {
        isBusy = true;
      });
      objectDetectionOutput = await objectDetector.runInference(tensorImage);
      setState(() {
        isBusy = false;
      });
    } on Exception catch (e) {
      setState(() {
        isBusy = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      if (!kDebugMode) {
        return;
      }
    }
    if (!mounted) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageScreen(
        tensorImage.image.clone(),
        objectDetectionOutput,
      ),
    ));
  }
}
