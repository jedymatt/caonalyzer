import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:caonalyzer/ui/screens/image_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool isBusy = false;
  ObjectDetectionOutput objectDetectionOutput = ObjectDetectionOutput.empty();
  late ObjectDetector objectDetector;

  @override
  void initState() {
    super.initState();
    objectDetector = preferredMode.value.objectDetector;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Pick Image'),
          ),
          isBusy ? const CircularProgressIndicator() : const SizedBox.shrink(),
          Text('Outputs count: ${objectDetectionOutput.numDetections}'),
        ],
      ),
    );
  }

  void pickImage() async {
    final imagePicker = ImagePicker();
    XFile? fileImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (fileImage == null) return;

    final imageBytes = await fileImage.readAsBytes();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    objectDetector = preferredMode.value.objectDetector;

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
