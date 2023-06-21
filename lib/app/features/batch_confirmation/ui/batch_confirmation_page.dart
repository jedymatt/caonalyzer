import 'dart:io';

import 'package:caonalyzer/app/features/batch/bloc/batch_bloc.dart';
import 'package:caonalyzer/app/features/batch/ui/batch_page.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path_lib;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class BatchConfirmationPage extends StatefulWidget {
  const BatchConfirmationPage(
      {super.key,
      required this.title,
      required this.batchPath,
      required this.images});

  final String batchPath;
  final String title;
  final List<String> images;

  static Route route({
    required String batchPath,
    required List<String> images,
  }) {
    return MaterialPageRoute(
      builder: (_) => BatchConfirmationPage(
        batchPath: batchPath,
        images: images,
        title: path_lib.basename(batchPath),
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
      listener: (context, state) {
        if (state is BatchConfirmationNavigateToBatchPageActionState) {
          if (ModalRoute.of(context)!.settings.name == 'BatchPage') {
            Navigator.of(context).pop();
          } else {
            BlocProvider.of<GalleryBloc>(context)
                .add(GalleryFetchImagesEvent());

            Navigator.of(context).pushAndRemoveUntil(
                BatchPage.route(
                  batchPath: state.batchPath,
                ),
                (route) => route.isFirst);
          }
        }

        if (state is BatchConfirmationRetakeImageState) {
          // todo: retake image
        }

        if (state is BatchConfirmationAddImageState) {
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
          onTap: (index) {
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
