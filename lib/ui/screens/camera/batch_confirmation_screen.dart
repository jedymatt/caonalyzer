import 'dart:io';

import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:flutter/material.dart';

import '../../gallery/screens/view_batch_screen.dart';

enum BottomNavigationIndex {
  retake,
  confirm,
}

class BatchConfirmationScreen extends StatefulWidget {
  const BatchConfirmationScreen(this.images, {super.key});

  final List<String> images;

  @override
  State<BatchConfirmationScreen> createState() =>
      _BatchConfirmationScreenState();
}

class _BatchConfirmationScreenState extends State<BatchConfirmationScreen> {
  late final String batchPath;

  @override
  void initState() {
    super.initState();

    batchPath = GalleryWriter.instance.generateBatchPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Image.file(File(widget.images.first)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (BottomNavigationIndex.values[index] ==
              BottomNavigationIndex.retake) {
            Navigator.of(context).pop();
          } else {
            confirm();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Retake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            backgroundColor: Colors.green,
            label: 'Confirm',
          ),
        ],
      ),
    );
  }

  void confirm() {
    // final batchPath =
    //     widget.batchPath ?? GalleryWriter.instance.generateBatchPath();
    //
    // if (widget.batchPath == null) {
    //   GalleryWriter.instance.createDirectory(batchPath);
    // }
    //
    // String path =
    //     await GalleryWriter.instance.appendImage(file.path, batchPath);
    // redirect to view batch screen
  }
}
