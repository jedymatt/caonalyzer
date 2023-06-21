import 'dart:io';

import 'package:caonalyzer/app/features/batch/bloc/batch_bloc.dart';
import 'package:caonalyzer/app/features/batch/ui/widgets/image_tile.dart';
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
    batchBloc = BatchBloc()
      ..add(BatchFetchImagesEvent(batchPath: widget.batchPath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => batchBloc,
      child: BlocBuilder<BatchBloc, BatchState>(
        buildWhen: (previous, current) => current is! BatchActionState,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              if (state is BatchSelectionModeState) {
                batchBloc.add(BatchCancelSelectionModeEvent(
                  images: state.images,
                ));

                return Future.value(false);
              }

              return Future.value(true);
            },
            child: Scaffold(
              appBar: BatchAppBar(title: title),
              body: Builder(
                builder: (context) {
                  if (state is BatchLoadingFetchImages) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is BatchSelectionModeState) {
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
                              if (state.selectedImages
                                  .contains(state.images[index])) {
                                batchBloc.add(BatchSelectMultipleImagesEvent(
                                  images: state.images,
                                  selectedImages: state.selectedImages
                                      .where((element) =>
                                          element != state.images[index])
                                      .toList(),
                                ));
                              } else {
                                batchBloc.add(BatchSelectMultipleImagesEvent(
                                  images: state.images,
                                  selectedImages: [
                                    ...state.selectedImages,
                                    state.images[index]
                                  ],
                                ));
                              }
                            },
                            onLongPress: () {},
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

                  if (state is BatchSuccessfulFetchImages) {
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
                                  builder: (context) => const ImagePage()));
                            },
                            onLongPress: () {
                              batchBloc.add(BatchSelectMultipleImagesEvent(
                                images: state.images,
                                selectedImages: [state.images[index]],
                              ));
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: Text('Unexpected Error'),
                  );
                },
              ),
            ),
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
    final batchBloc = context.read<BatchBloc>();

    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        if (state is BatchSelectionModeState) {
          return AppBar(
            title: Text('${state.selectedImages.length} selected'),
            leading: IconButton(
              onPressed: () {
                batchBloc.add(BatchCancelSelectionModeEvent(
                  images: state.images,
                ));
              },
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  batchBloc.add(BatchSelectMultipleImagesEvent(
                    images: state.images,
                    selectedImages: [...state.images],
                  ));
                },
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                // deselect
                onPressed: () {
                  batchBloc.add(BatchSelectMultipleImagesEvent(
                    images: state.images,
                    selectedImages: const [],
                  ));
                },
                icon: const Icon(Icons.deselect),
              ),
            ],
          );
        }

        if (state is BatchSuccessfulFetchImages) {
          return AppBar(title: Text(title), actions: [
            IconButton(
              onPressed: () {
                batchBloc.add(BatchSelectMultipleImagesEvent(
                  images: state.images,
                  selectedImages: const [],
                ));
              },
              icon: const Icon(Icons.checklist),
            )
          ]);
        }

        return AppBar(title: Text(title));
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
