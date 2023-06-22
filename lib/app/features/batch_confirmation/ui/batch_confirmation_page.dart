import 'dart:io';

import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path_lib;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class BatchConfirmationPage extends StatefulWidget {
  const BatchConfirmationPage({
    super.key,
    required this.title,
    required this.batchPath,
    required this.images,
    this.isFromBatchPage = false,
  });

  final String batchPath;
  final String title;
  final List<String> images;
  final bool isFromBatchPage;

  static Route route({
    required String batchPath,
    required List<String> images,
    bool isFromBatchPage = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => BatchConfirmationPage(
        batchPath: batchPath,
        images: images,
        title: path_lib.basename(batchPath),
        isFromBatchPage: isFromBatchPage,
      ),
    );
  }

  @override
  State<BatchConfirmationPage> createState() => _BatchConfirmationPageState();
}

class _BatchConfirmationPageState extends State<BatchConfirmationPage> {
  late final BatchConfirmationBloc batchConfirmationBloc;

  @override
  void initState() {
    super.initState();

    batchConfirmationBloc = BatchConfirmationBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BatchConfirmationBloc, BatchConfirmationState>(
      bloc: batchConfirmationBloc,
      listenWhen: (previous, current) =>
          current is BatchConfirmationActionState,
      listener: (context, state) async {
        if (state is BatchConfirmationNavigateToBatchPageActionState) {
          if (widget.isFromBatchPage) {
            Navigator.of(context)
              ..pop()
              ..pop();
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }

        if (state is BatchConfirmationRetakeImageState) {
          // todo: retake image
        }

        if (state is BatchConfirmationAddImageState) {
          if (!mounted) return;

          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
          onTap: (index) async {
            if (index == 0) {
              // retake
            }

            if (index == 1) {
              batchConfirmationBloc.add(BatchConfirmationAddImageEvent());
            }

            if (index == 2) {
              batchConfirmationBloc.add(
                BatchConfirmationSaveBatchEvent(
                  batchPath: widget.batchPath,
                  images: widget.images,
                ),
              );

              BlocProvider.of<GalleryBloc>(context)
                  .add(GalleryRefreshImagesEvent());
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
      ),
    );
  }
}
