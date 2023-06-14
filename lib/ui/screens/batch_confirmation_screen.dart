import 'dart:io';

import 'package:caonalyzer/controllers/gallery_controller.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path_lib;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../controllers/batch_confirmation_controller.dart';
import '../gallery/screens/view_batch_screen.dart';

class BatchConfirmationScreen extends StatefulWidget {
  const BatchConfirmationScreen(this.batchPath, this.images,
      {super.key, this.existingBatch = false});

  final String batchPath;
  final List<String> images;
  final bool existingBatch;

  @override
  State<BatchConfirmationScreen> createState() =>
      _BatchConfirmationScreenState();
}

class _BatchConfirmationScreenState extends State<BatchConfirmationScreen> {
  late final PageController _pageController;
  final controller = Get.put(BatchConfirmationController());

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    debugPrint('Existing Batch: ${widget.existingBatch}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batchPath),
      ),
      body: PhotoViewGallery(
        pageOptions: widget.images
            .map(
              (image) => PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(image)),
                heroAttributes: PhotoViewHeroAttributes(tag: image),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
            )
            .toList(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            // retake
          }

          if (index == 1) {
            Navigator.of(context).pop();
          }

          if (index == 2) {
            confirm();
          }
        },
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Retake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Add',
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

  void confirm() async => widget.existingBatch
        ?  controller.confirmExistingBatch(widget.batchPath, widget.images)
        :  controller.confirmNewBatch(widget.batchPath, widget.images);
}
