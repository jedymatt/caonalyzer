import 'dart:io';

import 'package:caonalyzer/app/features/batch/bloc/batch_bloc.dart';
import 'package:caonalyzer/app/features/batch/ui/widgets/image_tile.dart';
import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/batch_insights/ui/batch_insights_page.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/camera/ui/camera_page.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:caonalyzer/app/features/image/ui/image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path_lib;

class BatchPage extends StatefulWidget {
  const BatchPage({super.key, required this.batchPath});

  final String batchPath;

  static MaterialPageRoute route({required String batchPath}) {
    return MaterialPageRoute(
      builder: (_) => BatchPage(batchPath: batchPath),
    );
  }

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  late final String title;
  late final BatchBloc batchBloc;

  @override
  void initState() {
    super.initState();

    title = path_lib.basename(widget.batchPath);
    batchBloc = BatchBloc()..add(BatchStarted(batchPath: widget.batchPath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: batchBloc,
      child: BlocConsumer<BatchBloc, BatchState>(
        listenWhen: (previous, current) => current is BatchActionState,
        buildWhen: (previous, current) => current is! BatchActionState,
        listener: (context, state) {
          if (state is BatchNavigateToParentPageActionState) {
            BlocProvider.of<GalleryBloc>(context)
                .add(GalleryBatchesRefreshed());

            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
              if (state is BatchSuccess && state.selectionEnabled) {
                batchBloc.add(BatchImageSelectionDisabled());

                return Future.value(false);
              }

              return Future.value(true);
            },
            child: Scaffold(
                appBar: BatchAppBar(title: title),
                body: Builder(
                  builder: (context) {
                    if (state is BatchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is! BatchSuccess) {
                      return const Center(
                        child: Text('Unexpected Error'),
                      );
                    }

                    if (state.selectionEnabled) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 200,
                        ),
                        itemCount: state.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ImageTile(
                              image: FileImage(File(state.images[index])),
                              onTap: () {
                                // toggle
                                batchBloc.add(
                                    BatchImageSelectionToggled(index: index));
                              },
                              child: state.selectedImages
                                      .contains(state.images[index])
                                  ? Container(
                                      // gradient color
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 200,
                      ),
                      itemCount: state.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageTile(
                            image: FileImage(File(state.images[index])),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ImagePage(
                                  images: state.images,
                                  index: index,
                                ),
                              ));
                            },
                            onLongPress: () {
                              batchBloc.add(BatchImageSelectionEnabled(
                                startingSelectedIndex: index,
                              ));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                bottomNavigationBar: BottomAppBar(
                  child: BlocBuilder<BatchBloc, BatchState>(
                    builder: (context, state) {
                      if (state is! BatchSuccess) {
                        return const SizedBox.shrink();
                      }

                      if (state.selectionEnabled) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                batchBloc.add(BatchSelectedImagesDeleted());
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => BatchConfirmationBloc()
                                    ..add(BatchConfirmationStarted(
                                      batchPath: widget.batchPath,
                                    )),
                                  child: const CameraPage(
                                    mode: CameraCaptureMode.batch,
                                  ),
                                ),
                              ));
                            },
                            icon: const Icon(Icons.add_a_photo),
                            tooltip: 'Add a photo',
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BatchInsightsPage(
                                  images: state.images,
                                ),
                              ));
                            },
                            icon: const Icon(
                              Icons.insights,
                            ),
                            tooltip: 'Show results',
                          ),
                        ],
                      );
                    },
                  ),
                )),
          );
        },
      ),
    );
  }
}

class BatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BatchAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final batchBloc = BlocProvider.of<BatchBloc>(context);

    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        if (state is! BatchSuccess) {
          return AppBar(title: Text(title));
        }

        if (state.selectionEnabled) {
          return AppBar(
            title: Text('${state.selectedImages.length} selected'),
            leading: IconButton(
              onPressed: () {
                batchBloc.add(BatchImageSelectionDisabled());
              },
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  batchBloc.add(BatchAllImagesSelected());
                },
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                // deselect
                onPressed: () {
                  batchBloc.add(BatchAllImagesDeselected());
                },
                icon: const Icon(Icons.deselect),
              ),
            ],
          );
        }

        return AppBar(title: Text(title), actions: [
          IconButton(
            onPressed: () {
              batchBloc.add(BatchImageSelectionEnabled());
            },
            icon: const Icon(Icons.checklist),
          )
        ]);
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
