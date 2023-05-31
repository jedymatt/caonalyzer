import 'package:caonalyzer/object_detectors/enums/preferred_mode.dart';
import 'package:caonalyzer/object_detectors/object_detector.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/models/object_detection_output.dart';
import 'package:caonalyzer/screens/camera_screen.dart';
import 'package:caonalyzer/screens/image_screen.dart';
import 'package:caonalyzer/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<ObjectDetectionOutput> outputs = [];

  @override
  void initState() {
    super.initState();

    objectDetector = Get.find<PreferredMode>().objectDetector;
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
              Text('Outputs count: ${outputs.length}'),
              ...outputs.map(
                  (output) => Text('${output.label} - ${output.confidence}')),
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
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageBytes = await image.readAsBytes();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    setState(() {
      isBusy = true;
    });

    final prepImage = objectDetector.preProcessImage(decodedImage);

    try {
      objectDetector
          .runInference(prepImage)
          .then((value) => setState(() => outputs = value));
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

      return;
    }
    if (!mounted) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageScreen(prepImage.image, outputs),
    ));
  }
}
