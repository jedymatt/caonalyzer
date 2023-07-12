import 'dart:async';
import 'dart:io';

import 'package:caonalyzer/app/features/batch/ui/batch_page.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:caonalyzer/app/features/gallery/models/batch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GalleryFragment extends StatefulWidget {
  const GalleryFragment({super.key});

  @override
  State<GalleryFragment> createState() => _GalleryFragmentState();
}

class _GalleryFragmentState extends State<GalleryFragment> {
  late final GalleryBloc galleryBloc;
  late Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();

    galleryBloc = BlocProvider.of<GalleryBloc>(context);
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GalleryBloc, GalleryState>(
      bloc: galleryBloc,
      listenWhen: (previous, current) => current is GalleryActionState,
      buildWhen: (previous, current) => current is! GalleryActionState,
      listener: (context, state) {
        if (state is GalleryRefreshSuccess) {
          _refreshCompleter.complete();
          _refreshCompleter = Completer<void>();
        }
      },
      builder: (context, state) {
        if (state is GalleryInitial) {
          return const SizedBox.shrink();
        }

        if (state is GalleryInProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is! GallerySuccess) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // fetch the images in gallery
            galleryBloc.add(GalleryBatchesRefreshed());

            // sync the indicator with the bloc
            return _refreshCompleter.future;
          },
          child: state.batches.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.batches.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return BatchTile(
                      batch: state.batches[index],
                    );
                  },
                )
              : Container(
                  padding: const EdgeInsets.all(32),
                  child: SvgPicture.asset(
                    'assets/svgs/undraw_photograph_re_up3b.svg',
                  ),
                ),
        );
      },
    );
  }
}

class BatchTile extends StatelessWidget {
  const BatchTile({
    super.key,
    required this.batch,
  });

  final Batch batch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BatchPage(
            batchPath: batch.directory,
          ),
        ));
      },
      child: GridTile(
        footer: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            batch.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(batch.thumbnail)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
