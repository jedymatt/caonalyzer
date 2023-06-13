import 'dart:io';

import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:caonalyzer/ui/gallery/screens/view_batch_screen.dart';
import 'package:flutter/material.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  List<Batch> batches = [];

  bool _isListView = true;

  @override
  void initState() {
    super.initState();

    initBatches();
  }

  void initBatches() async {
    batches = await GalleryReader.getBatches();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewBatchScreen(batches[index]),
                        ),
                      ),
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.file(
                          File(batches[index].thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(batches[index].title),
                    );
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewBatchScreen(batches[index]),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(
                                File(batches[index].thumbnail),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(batches[index].title),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
