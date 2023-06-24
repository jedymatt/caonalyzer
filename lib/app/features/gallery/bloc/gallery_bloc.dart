import 'dart:async';
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
    on<GalleryStarted>(_onStarted);
    on<GalleryImagesRefreshed>(_onImageRefreshed);
  }

  FutureOr<void> _onStarted(event, emit) async {
    emit(GalleryLoading());
    emit(GallerySuccess(batches: await _getBatches()));
  }

  FutureOr<void> _onImageRefreshed(event, emit) async {
    if (state is! GallerySuccess) return;

    final state_ = state as GallerySuccess;

    if (state_.refreshing) return;

    emit(state_.copyWith(refreshing: true));

    emit(GallerySuccess(batches: await _getBatches()));
  }

  Future<List<Batch>> _getBatches() async {
    final batchPaths = await GalleryReader.getBatchPaths();

    return batchPaths
        .map((e) => Batch(
              title: path_lib.basename(e),
              directory: e,
              thumbnail: Directory(e).listSync().first.path,
            ))
        .toList();
  }
}
