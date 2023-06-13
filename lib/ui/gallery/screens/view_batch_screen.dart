import 'dart:io';

import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/ui/gallery/screens/image_screen.dart';
import 'package:flutter/material.dart';

import '../../screens/camera_screen.dart';

class ViewBatchScreen extends StatefulWidget {
  const ViewBatchScreen(this.batch, {super.key});

  final Batch batch;

  @override
  State<ViewBatchScreen> createState() => _ViewBatchScreenState();
}

class _ViewBatchScreenState extends State<ViewBatchScreen> {
  bool _isSelecting = false;
  final List<String> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: widget.batch.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onLongPress: () {
                      if (_isSelecting) return;

                      setState(() {
                        _isSelecting = true;
                      });
                      addToSelection(widget.batch.images[index]);
                    },
                    onTap: _isSelecting
                        ? () => toggleSelection(widget.batch.images[index])
                        : () =>
                            redirectToImageViewer(widget.batch.images[index]),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(widget.batch.images[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        // checkmark in top right corner
                        if (_isSelecting)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _selectedImages
                                        .contains(widget.batch.images[index])
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        // highlight box around the image
                        if (_isSelecting &&
                            _selectedImages
                                .contains(widget.batch.images[index]))
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Text('${index + 1}'),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void redirectToImageViewer(String image) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageScreen(
        widget.batch.images,
        initialIndex: widget.batch.images.indexOf(image),
      ),
    ));
  }

  Widget? _buildBottomNavigationBar() {
    return _isSelecting
        ? _selectingImageBottomNav()
        : _notSelectingImageBottomNav();
  }

  Widget? _selectingImageBottomNav() {
    if (_selectedImages.isEmpty) return null;

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.delete),
          label: 'Delete',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Scan',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // delete
            final isNowEmpty = widget.batch.images.length == _selectedImages.length;

            GalleryWriter.removeImages(_selectedImages);
            setState(() {
              _isSelecting = false;
              _selectedImages.clear();
            });

            if (isNowEmpty) {
              Navigator.of(context).pop();
            }

            break;
          case 1:
            // scan
            break;
        }
      },
    );
  }

  Widget _notSelectingImageBottomNav() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_a_photo),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Scan',
        ),
        // more
        BottomNavigationBarItem(
          icon: Icon(Icons.more_vert),
          label: 'More',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // camera
            debugPrint(widget.batch.toString());
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CameraScreen(batchPath: widget.batch.dirPath),
            ));
            break;
          case 1:
            // scan
            break;
          case 2:
            // open more menu
            break;
        }
      },
    );
  }

  void addToSelection(String image) {
    setState(() {
      // add picture to selection but only if it's not already selected
      if (!_selectedImages.contains(image)) {
        _selectedImages.add(image);
      }
    });
  }

  void toggleSelection(String image) {
    setState(() {
      // remove picture from selection if it's already selected
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else {
        _selectedImages.add(image);
      }
    });
  }

  AppBar _buildAppBar() {
    return _isSelecting ? _appBarSelection() : _appBarDefault();
  }

  AppBar _appBarDefault() {
    return AppBar(
      title: Text(widget.batch.title),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSelecting = true;
            });
          },
          icon: const Icon(Icons.checklist),
        ),
      ],
    );
  }

  AppBar _appBarSelection() {
    return AppBar(
      title: Text('${_selectedImages.length} selected'),
      leading: IconButton(
        onPressed: () {
          setState(() {
            _isSelecting = false;
            _selectedImages.clear();
          });
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        if (_selectedImages.length != widget.batch.images.length)
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImages.clear();
                _selectedImages.addAll(widget.batch.images);
              });
            },
            icon: const Icon(Icons.select_all),
          )
        else
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImages.clear();
              });
            },
            icon: const Icon(Icons.deselect),
          ),
      ],
    );
  }
}
