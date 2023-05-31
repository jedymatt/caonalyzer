import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/predictor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'camera_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String message = '';

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
              Text(
                message,
                overflow: TextOverflow.visible,
              ),
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
    final img.Image preImage = img.decodeImage(imageBytes)!;
    setState(() {
      runInference(preImage).then((value) => message = value.toString());
    });
  }
}
