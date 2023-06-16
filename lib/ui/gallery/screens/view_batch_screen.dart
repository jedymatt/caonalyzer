import 'dart:io';

import 'package:caonalyzer/controllers/view_batch_screen_controller.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/ui/gallery/screens/image_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewBatchScreen extends StatefulWidget {
  const ViewBatchScreen(this.batch, {super.key});

  final Batch batch;

  @override
  State<ViewBatchScreen> createState() => _ViewBatchScreenState();
}

class _ViewBatchScreenState extends State<ViewBatchScreen> {
  late final ViewBatchScreenController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      ViewBatchScreenController(widget.batch),
      tag: widget.batch.dirPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (controller.isSelecting.value) {
          controller.stopSelecting();

          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Obx(() => Scaffold(
            appBar: _buildAppBar(),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 200,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: controller.images.length,
              itemBuilder: (context, index) => buildImageTile(index),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          )),
    );
  }

  Widget buildImageTile(int index) {
    const strokeWidth = 4.0;

    return Container(
      margin: const EdgeInsets.all(strokeWidth),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: controller.isSelecting.value &&
                controller.selectedImages.contains(controller.images[index])
            ? Border.all(
                color: Colors.blue,
                width: 4,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
      child: Card(
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () {
            if (controller.isSelecting.value) return;

            controller.toggleSelecting();

            controller.toggleSelect(controller.images[index]);
          },
          onTap: controller.isSelecting.value
              ? () => controller.toggleSelect(controller.images[index])
              : () => redirectToImageViewer(controller.images[index]),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Ink.image(
            image: FileImage(File(controller.images[index])),
            fit: BoxFit.cover,
            onImageError: (exception, stackTrace) => const Icon(Icons.error),
            child: controller.isSelecting.value
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(strokeWidth),
                      child: Icon(
                        controller.selectedImages
                                .contains(controller.images[index])
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void redirectToImageViewer(String image) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageScreen(
        controller.images,
        initialIndex: controller.images.indexOf(image),
      ),
    ));
  }

  Widget _buildBottomNavigationBar() {
    return controller.isSelecting.value
        ? _selectingImageBottomNav()
        : _notSelectingImageBottomNav();
  }

  Widget _selectingImageBottomNav() {
    if (controller.selectedImages.isEmpty) return const SizedBox.shrink();

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.delete),
          label: 'Delete',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Scan',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            controller.deleteSelected();
            break;
          case 1:
            // scan
            break;
        }
      },
    );
  }

  Widget _notSelectingImageBottomNav() {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            // label: 'Camera',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.document_scanner),
            // label: 'Scan',
            onPressed: () {},
          ),
          // more
          IconButton(
            icon: Icon(Icons.more_vert),
            // label: 'More',
            onPressed: () {},
          ),
        ],
        // onTap: (index) async {
        //   switch (index) {
        //     case 0:
        //       // camera
        //       debugPrint(widget.batch.toString());
        //       Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) =>
        //             CameraScreen(batchPath: widget.batch.dirPath),
        //       ));
        //       break;
        //     case 1:
        //       // scan
        //       // todo: migrate to controller
        //       final objectDetector = Globals.preferredMode.value.objectDetector;

        //       for (var image in controller.images) {
        //         final tensorImage = objectDetector.preprocessImage(
        //             image_lib.decodeImage(File(image).readAsBytesSync())!);

        //         final outputs = await objectDetector.runInference(tensorImage);

        //         MetadataWriter.create(
        //           image,
        //           ImageMetadata(
        //             imagePath: image,
        //             objectDetectionMode: Globals.preferredMode.value.toString(),
        //             objectDetectionOutputs: outputs.map((e) {
        //               return ObjectDetectionOutput(
        //                 class_: e.label,
        //                 confidence: e.confidence,
        //                 boxes: e.boundingBox.toLTRBList(),
        //               );
        //             }).toList(),
        //           ),
        //         );
        //       }

        //       break;
        //     case 2:
        //       // open more menu
        //       break;
        //   }
        // },
      ),
    );
  }

  AppBar _buildAppBar() {
    return _appBarDefault();
  }

  AppBar _appBarDefault() {
    return AppBar(
      title: controller.isSelecting.value
          ? Text('${controller.selectedImages.length} selected')
          : Text(widget.batch.title),
      leading: controller.isSelecting.value
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.stopSelecting,
            )
          : null,
      actions: [
        !controller.isSelecting.value
            ? IconButton(
                onPressed: () {
                  controller.isSelecting.value = true;
                },
                icon: const Icon(Icons.checklist),
              )
            : const SizedBox.shrink(),
        controller.isSelecting.value
            ? IconButton(
                onPressed: controller.deselectAll,
                icon: const Icon(Icons.deselect),
              )
            : const SizedBox.shrink(),
        controller.isSelecting.value
            ? IconButton(
                onPressed: controller.selectAll,
                icon: const Icon(Icons.select_all),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
