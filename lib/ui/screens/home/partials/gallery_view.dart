import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/gallery/models/picture.dart';
import 'package:caonalyzer/ui/gallery/screens/view_batch_screen.dart';
import 'package:flutter/material.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  bool _isListView = true;

  @override
  Widget build(BuildContext context) {
    Batch batch = Batch(
      title: 'Batch 1',
      path: 'path/to/batch',
      date: '2020-01-01',
      pictures: [
        Picture(
          id: 1,
          path: 'path/to/picture',
          date: '2020-01-01',
        ),
        Picture(
          id: 2,
          path: 'path/to/picture',
          date: '2020-01-01',
        ),
        Picture(
          id: 3,
          path: 'path/to/picture',
          date: '2020-01-01',
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isListView = !_isListView;
                    });
                  },
                  icon: Icon(
                    _isListView ? Icons.grid_view : Icons.list,
                  )),
            ],
          ),
          _isListView
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batch.pictures.length * 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewBatchScreen(batch),
                        ),
                      ),
                      leading: const Placeholder(
                        child: Text('Thumbnail'),
                      ),
                      title: Text(batch.title),
                    );
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batch.pictures.length * 10,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              batch.pictures.last.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(batch.date),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
