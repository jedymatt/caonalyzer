import 'dart:io';

import 'package:caonalyzer/app/features/batch/ui/batch_page.dart';
import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryFragment extends StatefulWidget {
  const GalleryFragment({super.key});

  @override
  State<GalleryFragment> createState() => _GalleryFragmentState();
}

class _GalleryFragmentState extends State<GalleryFragment> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      buildWhen: (previous, current) => current is! GalleryActionState,
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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BatchPage(
                    batchPath: state.batches[index].directory,
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
