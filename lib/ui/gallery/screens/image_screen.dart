import 'dart:developer' as developer;

import 'package:caonalyzer/gallery/models/picture.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen(this.pictures, {super.key, this.initialIndex = 0});

  final List<Picture> pictures;
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
    imageTitle = widget.pictures[widget.initialIndex].id.toString();
    _pageController = PageController(initialPage: widget.initialIndex);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imageTitle),
        bottom: widget.pictures.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / widget.pictures.length,
                ),
              )
            : null,
      ),
      body: PhotoViewGallery(
        pageController: _pageController,
        pageOptions: widget.pictures
            .map(
              (picture) => PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(picture.path),
                heroAttributes: PhotoViewHeroAttributes(tag: picture.id),
                minScale: PhotoViewComputedScale.contained,
              ),
            )
            .toList(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        onPageChanged: (index) {
          debugPrint('index: $index picturesLength: ${widget.pictures.length}');
          setState(() {
            currentIndex = index;
            imageTitle = widget.pictures[index].id.toString();
          });
        },
      ),
    );
  }
}
