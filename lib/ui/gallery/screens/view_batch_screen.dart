import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/gallery/models/picture.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/screens/camera_screen.dart';
import 'package:flutter/material.dart';

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
              child: GestureDetector(
                onLongPress: _isSelecting
                    ? null
                    : () {
                        setState(() {
                          _isSelecting = true;
                        });
                        addToSelection(widget.batch.pictures[index]);
                      },
                onTap: _isSelecting
                    ? () => toggleSelection(widget.batch.pictures[index])
                    : null,
                child: GridTile(
                  footer: Center(
                      child: Text(widget.batch.pictures[index].id.toString())),
                  child: const Placeholder(
                    child: Center(child: Text('Thumbnail')),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context));
  }

  BottomNavigationBar? _buildBottomNavigationBar(BuildContext context) {
    if (_isSelecting && _selectedPictures.isEmpty) return null;

    if (_isSelecting) {
      return BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
          // detect moldy cacao beans
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // todo: delete selected pictures
              break;
            case 1:
              // todo: detect moldy cacao beans
              break;
          }
        },
      );
    }

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.add_circle),
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        // detect moldy cacao beans
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Scan',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // add image
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ));
            break;
          case 1:
            // detect moldy cacao beans
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
    List<Widget> actions = [];
    Widget title = Text(widget.batch.title);

    if (_isSelecting) {
      actions = [
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
      ];
      title = Text('${_selectedPictures.length} selected');
    }

    return AppBar(
      leading: _isSelecting
          ? IconButton(
              onPressed: () {
                setState(() {
                  _isSelecting = false;
                  _selectedPictures.clear();
                });
              },
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      title: title,
      actions: actions,
    );
  }
}
