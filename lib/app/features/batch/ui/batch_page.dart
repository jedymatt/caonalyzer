import 'dart:io';

import 'package:caonalyzer/app/features/batch/bloc/batch_bloc.dart';
import 'package:caonalyzer/app/features/batch/ui/widgets/batch_app_bar.dart';
import 'package:caonalyzer/app/features/batch/ui/widgets/image_tile.dart';
import 'package:caonalyzer/app/features/image/ui/image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path_lib;

class BatchPage extends StatefulWidget {
  const BatchPage({super.key, required this.batchPath});

  final String batchPath;

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  late final String title;

  @override
  void initState() {
    super.initState();

    title = path_lib.basename(widget.batchPath);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BatchBloc()..add(BatchFetchImagesEvent(batchPath: widget.batchPath)),
      child: BlocBuilder<BatchBloc, BatchState>(
        buildWhen: (previous, current) => current is! BatchActionState,
        builder: (context, state) {
          final batchBloc = BlocProvider.of<BatchBloc>(context);
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ImagePage()));
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
