import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/locator.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_lib;

part 'batch_event.dart';

part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  BatchBloc() : super(BatchInitial()) {
    on<BatchStarted>(_onStarted);
    on<BatchImageSelectionEnabled>(_onImageSelectionEnabled);
    on<BatchImageSelectionDisabled>(_onSelectionDisabled);
    on<BatchSelectedImagesDeleted>(_onSelectedImagesDeleted);
    on<BatchImageSelectionToggled>(_onImageSelectionToggled);
    on<BatchAllImagesSelected>(_onAllImagesSelected);
    on<BatchAllImagesDeselected>(_onAllImagesDeselected);
  }

  FutureOr<void> _onImageSelectionEnabled(event, emit) {
    if (state is BatchSuccess) {
      final state_ = state as BatchSuccess;

      emit(state_.copyWith(
        selectionEnabled: true,
        selectedImages: event.startingSelectedIndex != null
            ? [state_.images[event.startingSelectedIndex!]]
            : const [],
      ));
    }
  }

  FutureOr<void> _onAllImagesDeselected(event, emit) {
    if (state is BatchSuccess && (state as BatchSuccess).selectionEnabled) {
      final state_ = state as BatchSuccess;

      emit(state_.copyWith(
        selectedImages: const [],
      ));
    }
  }

  FutureOr<void> _onAllImagesSelected(event, emit) {
    if (state is BatchSuccess && (state as BatchSuccess).selectionEnabled) {
      final state_ = state as BatchSuccess;

      emit(state_.copyWith(
        selectedImages: List.from(state_.images),
      ));
    }
  }

  FutureOr<void> _onImageSelectionToggled(
      BatchImageSelectionToggled event, Emitter<BatchState> emit) {
    if (state is BatchSuccess && (state as BatchSuccess).selectionEnabled) {
      final state_ = state as BatchSuccess;

      final image = state_.images[event.index];

      emit(state_.copyWith(
        selectedImages: state_.selectedImages.contains(image)
            ? (List.from(state_.selectedImages)
              ..removeWhere((selectedImage) => selectedImage == image))
            : (List.from(state_.selectedImages)..add(image)),
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

  FutureOr<void> _onSelectedImagesDeleted(
      BatchSelectedImagesDeleted event, Emitter<BatchState> emit) async {
    if (state is BatchSuccess && (state as BatchSuccess).selectionEnabled) {
      final state_ = state as BatchSuccess;

      emit(BatchDeletingImagesState());

      GalleryWriter.removeImages(state_.selectedImages);
      final service = locator.get<DetectedObjectService>();
      for (var e in state_.selectedImages) {
        service.deleteAll(e);
      }

      final batchPath = path_lib.dirname(state_.images.first);

      final remainingImages = (await GalleryReader.getImages(batchPath))
          .map((e) => e.path)
          .toList();

      if (remainingImages.isEmpty) {
        GalleryWriter.deleteDirectory(batchPath);
        emit(BatchDeletedState());
        return;
      }

      if (remainingImages[0] != state_.images[0]) {
        emit(BatchCoverImageChangedState());
      }

      emit(BatchSuccess(
        images: remainingImages,
        selectionEnabled: false,
      ));
    }
  }

  FutureOr<void> _onSelectionDisabled(event, emit) {
    if (state is BatchSuccess && (state as BatchSuccess).selectionEnabled) {
      final state_ = state as BatchSuccess;

      emit(state_.copyWith(
        selectionEnabled: false,
        selectedImages: [],
      ));
    }
  }
}
