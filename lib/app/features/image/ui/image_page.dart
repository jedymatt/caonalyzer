import 'dart:io';

import 'package:caonalyzer/app/features/image/bloc/image_bloc.dart';
import 'package:caonalyzer/app/features/image/ui/bounding_box_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:caonalyzer/app/features/image/models/image.dart' as models;

class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.images, this.index = 0});

  final List<String> images;
  final int index;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late final ImageBloc imageBloc;

  @override
  void initState() {
    super.initState();
    imageBloc = ImageBloc(
        images: widget.images.map((e) => models.Image(path: e)).toList(),
        initialIndex: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: imageBloc,
      child: BlocConsumer<ImageBloc, ImageState>(
        bloc: imageBloc,
        listenWhen: (_, current) =>
            current is ImageInitial &&
            current.detectionStatus == ImageDetectionStatus.failure,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Online mode failed, no network connection or server is down.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          return Scaffold(
            appBar: const ImageAppBar(),
            body: BlocBuilder<ImageBloc, ImageState>(
              bloc: imageBloc,
              buildWhen: (previous, current) => current is ImageInitial,
              builder: (context, state) {
                if (state is! ImageInitial) return const SizedBox.shrink();

                return Stack(
                  children: [
                    // do custom paint instead of saving a preview image
                    PhotoViewGallery.builder(
                      pageController: imageBloc.controller,
                      itemCount: widget.images.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions.customChild(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: CustomPaint(
                              foregroundPainter: BoundingBoxPainter(
                                (state.showDetection &&
                                            state.detectionStatus ==
                                                ImageDetectionStatus.success) &&
                                        state.images[state.index]
                                                .detectedObjects !=
                                            null
                                    ? state.images[state.index].detectedObjects!
                                    : [],
                              ),
                              child: Image.file(
                                File(state.images[index].path),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.contained * 2.5,
                        );
                      },
                      scaleStateChangedCallback: (scaleState) {
                        ImageScale scale;

                        switch (scaleState) {
                          case PhotoViewScaleState.zoomedIn:
                            scale = ImageScale.zoomIn;
                            break;
                          case PhotoViewScaleState.zoomedOut:
                            scale = ImageScale.zoomOut;
                            break;
                          default:
                            scale = ImageScale.none;
                        }
                        debugPrint('scale changed: $scale');
                        imageBloc.add(ImageScaleChanged(scale: scale));
                      },
                      onPageChanged: (index) {
                        imageBloc.add(ImagePageChanged(index: index));
                      },
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                    if (state.detectionStatus ==
                        ImageDetectionStatus.inProgress)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if ((state.showDetection &&
                            state.detectionStatus ==
                                ImageDetectionStatus.success) &&
                        state.scale != ImageScale.zoomIn)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Moldy Count: ${state.images[state.index].detectedObjects?.length}',
                          ),
                        ),
                      )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ImageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageBloc, ImageState>(
      bloc: BlocProvider.of<ImageBloc>(context),
      buildWhen: (previous, current) => current is ImageInitial,
      builder: (context, state) {
        if (state is! ImageInitial) {
          return AppBar();
        }

        return AppBar(
          title: Text('${state.index + 1}/${state.images.length}'),
          centerTitle: true,
          actions: [
            // show/hide button
            IconButton(
              icon: Icon(state.showDetection
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed:
                  state.detectionStatus != ImageDetectionStatus.inProgress
                      ? () => BlocProvider.of<ImageBloc>(context)
                          .add(ImageDetectionToggled())
                      : null,
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
