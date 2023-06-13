import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen(this.images, {super.key, this.initialIndex = 0});

  final List<String> images;
  final int initialIndex;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late final PageController _pageController;
  late String imageTitle;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    imageTitle = '${currentIndex + 1}/${widget.images.length}';
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${currentIndex + 1}/${widget.images.length}',
        ),
        centerTitle: true,
        bottom: widget.images.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / widget.images.length,
                ),
              )
            : null,
      ),
      body: PhotoViewGallery(
        pageController: _pageController,
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
          color: Theme.of(context).colorScheme.background,
        ),
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        onPageChanged: (index) {
          debugPrint('index: $index picturesLength: ${widget.images.length}');
          setState(() {
            currentIndex = index;
            imageTitle = '${currentIndex + 1}/${widget.images.length}';
          });
        },
      ),
    );
  }
}
