import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:caonalyzer/app/features/gallery/models/batch.dart';
import 'package:path/path.dart' as path_lib;

part 'gallery_event.dart';

part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(GalleryInitial()) {
    on<GalleryInitialEvent>((event, emit) async {
      emit(GalleryLoading());
      final batchPaths = await GalleryReader.getBatchPaths();
      var batches = batchPaths
          .map((e) => Batch(
                title: path_lib.basename(e),
                directory: e,
                thumbnail: Directory(e).listSync().first.path,
              ))
          .toList();

      emit(GalleryLoaded(batches: batches));
    });

    on<GalleryFetchImagesEvent>((event, emit) async {
      emit(GalleryLoading());

      final batchPaths = await GalleryReader.getBatchPaths();
      var batches = batchPaths
          .map((e) => Batch(
                title: path_lib.basename(e),
                directory: e,
                thumbnail: Directory(e).listSync().first.path,
              ))
          .toList();

      emit(GalleryLoaded(batches: batches));
    });
  }
}
