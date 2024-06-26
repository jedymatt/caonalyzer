import 'dart:io';

import 'package:caonalyzer/app/features/batch/ui/batch_page.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/camera/ui/camera_page.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:caonalyzer/app/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class BatchConfirmationPage extends StatefulWidget {
  const BatchConfirmationPage({
    super.key,
    this.isFromBatchPage = false,
  });

  final bool isFromBatchPage;

  static Route route({
    bool isFromBatchPage = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => BatchConfirmationPage(
        isFromBatchPage: isFromBatchPage,
      ),
    );
  }

  @override
  State<BatchConfirmationPage> createState() => _BatchConfirmationPageState();
}

class _BatchConfirmationPageState extends State<BatchConfirmationPage> {
  late final BatchConfirmationBloc batchConfirmationBloc;
  bool isPageNumberVisible = true;

  @override
  void initState() {
    super.initState();

    batchConfirmationBloc = BlocProvider.of<BatchConfirmationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BatchConfirmationBloc>.value(
      value: batchConfirmationBloc,
      child: BlocListener<BatchConfirmationBloc, BatchConfirmationState>(
        bloc: batchConfirmationBloc,
        listenWhen: (previous, current) =>
            current is BatchConfirmationActionState,
        listener: (context, state) {
          if (state is BatchConfirmationSaveBatchSuccess) {
            batchConfirmationBloc.close();
            if (widget.isFromBatchPage) {
              // pop until batch page
              Navigator.of(context).pushAndRemoveUntil(
                BatchPage.route(
                  batchPath: state.batchPath,
                ),
                (route) => route.isFirst,
              );
            } else {
              BlocProvider.of<GalleryBloc>(context)
                  .add(GalleryBatchesRefreshed());

              BlocProvider.of<HomeBloc>(context)
                  .add(HomeTabChangedEvent(tab: HomeTab.gallery));

              Navigator.of(context).pushAndRemoveUntil(
                BatchPage.route(
                  batchPath: state.batchPath,
                ),
                (route) => route.isFirst,
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Batch'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: BlocBuilder<BatchConfirmationBloc, BatchConfirmationState>(
            bloc: batchConfirmationBloc,
            builder: (context, state) {
              if (state is! BatchConfirmationInitial) {
                return const SizedBox.shrink();
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  PhotoViewGallery(
                    pageOptions: state.images
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
                    onPageChanged: (index) {
                      batchConfirmationBloc
                          .add(BatchConfirmationImagePageChanged(index: index));
                    },
                    scaleStateChangedCallback: (value) {
                      setState(() {
                        isPageNumberVisible =
                            value != PhotoViewScaleState.zoomedIn;
                      });
                    },
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isPageNumberVisible)
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .canvasColor
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '${state.currentIndex + 1}/${state.images.length}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              );
            },
          ),
          bottomNavigationBar:
              BlocBuilder<BatchConfirmationBloc, BatchConfirmationState>(
            bloc: batchConfirmationBloc,
            builder: (context, state) {
              if (state is! BatchConfirmationInitial) {
                return const SizedBox.shrink();
              }

              return BottomNavigationBar(
                onTap: (index) async {
                  if (index == 0) {
                    // retake
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: batchConfirmationBloc,
                        child: CameraPage(
                          existingBatchPath: state.batchPath,
                          mode: CameraCaptureMode.single,
                        ),
                      ),
                    ));
                    return;
                  }

                  // add image
                  if (index == 1) {
                    Navigator.of(context).pop();
                  }

                  // confirm
                  if (index == 2) {
                    batchConfirmationBloc.add(BatchConfirmationBatchSaved());
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
              );
            },
          ),
        ),
      ),
    );
  }
}
