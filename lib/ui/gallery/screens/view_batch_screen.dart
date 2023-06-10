import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/gallery/models/picture.dart';
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
  List<Picture> _selectedPictures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: widget.batch.pictures.length,
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
                      addToSelection(widget.batch.pictures[index]);
                    },
                    onTap: _isSelecting
                        ? () => toggleSelection(widget.batch.pictures[index])
                        : () =>
                            redirectToImageViewer(widget.batch.pictures[index]),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.batch.pictures[index].thumbnail,
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
                                _selectedPictures
                                        .contains(widget.batch.pictures[index])
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        // highlight box around the image
                        if (_isSelecting &&
                            _selectedPictures
                                .contains(widget.batch.pictures[index]))
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
                Text(widget.batch.pictures[index].id.toString()),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void redirectToImageViewer(Picture picture) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageScreen(
        widget.batch.pictures,
        initialIndex: widget.batch.pictures.indexOf(picture),
      ),
    ));
  }

  Widget? _buildBottomNavigationBar() {
    return _isSelecting
        ? _selectingImageBottomNav()
        : _notSelectingImageBottomNav();
  }

  Widget? _selectingImageBottomNav() {
    if (_selectedPictures.isEmpty) return null;

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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CameraScreen(),
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

  void addToSelection(Picture picture) {
    setState(() {
      // add picture to selection but only if it's not already selected
      if (!_selectedPictures.contains(picture)) {
        _selectedPictures.add(picture);
      }
    });
  }

  void toggleSelection(Picture picture) {
    setState(() {
      // remove picture from selection if it's already selected
      if (_selectedPictures.contains(picture)) {
        _selectedPictures.remove(picture);
      } else {
        _selectedPictures.add(picture);
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
      title: Text('${_selectedPictures.length} selected'),
      leading: IconButton(
        onPressed: () {
          setState(() {
            _isSelecting = false;
            _selectedPictures.clear();
          });
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        if (_selectedPictures.length != widget.batch.pictures.length)
          IconButton(
            onPressed: () {
              setState(() {
                _selectedPictures.clear();
                _selectedPictures.addAll(widget.batch.pictures);
              });
            },
            icon: const Icon(Icons.select_all),
          )
        else
          IconButton(
            onPressed: () {
              setState(() {
                _selectedPictures.clear();
              });
            },
            icon: const Icon(Icons.deselect),
          ),
      ],
    );
  }
}
