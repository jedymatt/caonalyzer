import 'dart:io';

import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryFragment extends StatefulWidget {
  const GalleryFragment({super.key});

  @override
  State<GalleryFragment> createState() => _GalleryFragmentState();
}

class _GalleryFragmentState extends State<GalleryFragment> {
  final GalleryBloc galleryBloc = GalleryBloc();

  @override
  void initState() {
    super.initState();
    galleryBloc.add(GalleryInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GalleryBloc, GalleryState>(
      bloc: galleryBloc,
      listenWhen: (previous, current) => current is GalleryActionState,
      buildWhen: (previous, current) => current is! GalleryActionState,
      listener: (context, state) {
        if (state is GalleryNavigateToBatchActionState) {
          debugPrint('Navigate to batch ${state.batch.title}');
          // todo: navigate to batch page
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => BatchPage()));
        }
      },
      builder: (context, state) {
        if (state is GalleryInitial || state is GalleryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is! GalleryLoaded) {
          debugPrint('Something went wrong ${state.runtimeType}');
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.batches.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                galleryBloc.add(
                  GalleryNavigateToBatchEvent(
                    batch: state.batches[index],
                  ),
                );
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
                    state.batches[index].title,
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
                      image: FileImage(
                        File(state.batches[index].thumbnail),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
