import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_lib;

part 'batch_event.dart';

part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  BatchBloc() : super(BatchInitial()) {
    on<BatchStarted>(_onStarted);
    on<BatchImagesSelected>(_onImagesSelected);
    on<BatchImageSelectionCanceled>(_onSelectionCanceled);
    on<BatchImagesDeleted>(_onImagesDeleted);
  }

  FutureOr<void> _onImagesDeleted(event, emit) async {
    emit(BatchDeletingImagesState());
    GalleryWriter.removeImages(event.images);
    final batchPath = path_lib.dirname(event.images.first);

    final remainingImages =
        (await GalleryReader.getImages(batchPath)).map((e) => e.path).toList();

    if (remainingImages.isEmpty) {
      GalleryWriter.deleteDirectory(batchPath);
      emit(BatchNavigateToParentPageActionState());
      return;
    }

    emit(BatchSuccess(
      images: remainingImages,
    ));

    if (remainingImages.isEmpty) {
      GalleryWriter.deleteDirectory(batchPath);
      emit(BatchNavigateToParentPageActionState());
    }
  }

  FutureOr<void> _onSelectionCanceled(event, emit) {
    if (state is BatchSelectionModeState) {
      final state_ = state as BatchSelectionModeState;

      emit(BatchSuccess(images: state_.images));
    }
  }

  FutureOr<void> _onImagesSelected(event, emit) {
    if (state is BatchSuccess) {
      final state_ = state as BatchSuccess;

      emit(BatchSelectionModeState(
        images: state_.images,
        selectedImages: event.selectedImages.toSet().toList(),
      ));
    }
  }

  FutureOr<void> _onStarted(event, emit) async {
    emit(BatchLoading());

    final images = await GalleryReader.getImages(event.batchPath);

    emit(BatchSuccess(
      images: images.map((e) => e.path).toList(),
    ));
  }
}
