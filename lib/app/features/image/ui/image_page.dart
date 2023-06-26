import 'dart:io';

import 'package:caonalyzer/app/features/image/bloc/image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
    imageBloc = ImageBloc(images: widget.images, initialIndex: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: imageBloc,
      child: Scaffold(
        appBar: const ImageAppBar(),
        body: BlocBuilder<ImageBloc, ImageState>(
          bloc: imageBloc,
          builder: (context, state) {
            if (state is! ImageInitial) return const SizedBox.shrink();

            return PhotoViewGallery.builder(
              pageController: imageBloc.controller,
              itemCount: widget.images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(widget.images[index])),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 2.5,
                );
              },
              onPageChanged: (index) {
                imageBloc.add(ImagePageChanged(index: index));
              },
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
            );
          },
        ),
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
      builder: (context, state) {
        if (state is! ImageInitial) {
          return AppBar();
        }

        return AppBar(
          title: Text('${state.index + 1}/${state.images.length}'),
          centerTitle: true,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
