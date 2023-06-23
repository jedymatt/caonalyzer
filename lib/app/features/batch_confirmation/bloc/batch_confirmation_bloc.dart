import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_lib;

part 'batch_confirmation_event.dart';
part 'batch_confirmation_state.dart';

class BatchConfirmationBloc
    extends Bloc<BatchConfirmationEvent, BatchConfirmationState> {
  BatchConfirmationBloc(
      {required List<String> images, required String batchPath})
      : super(BatchConfirmationInitial(batchPath: batchPath, images: images)) {
    on<BatchConfirmationImageAdded>(_onImageAdded);

    on<BatchConfirmationImagePageChanged>(_onImagePageChanged);

    on<BatchConfirmationImageRetaked>(_onImageRetaked);

    on<BatchConfirmationBatchSaved>(_onBatchSaved);
  }

  FutureOr<void> _onBatchSaved(event, emit) async {
    if (state is BatchConfirmationInitial) {
      final state_ = state as BatchConfirmationInitial;

      emit(BatchConfirmationLoadingSaveBatchState());

      final batchPath = path_lib.dirname(state_.images.first);

      // if batchPath is does not exist, create it
      if (!GalleryReader.batchExists(batchPath)) {
        GalleryWriter.createDirectory(batchPath);
      }

      await GalleryWriter.appendImages(state_.images, state_.batchPath);

      emit(BatchConfirmationNavigateToBatchPageActionState(
        batchPath: state_.batchPath,
      ));
    }
  }

  FutureOr<void> _onImageAdded(event, emit) {
    emit(BatchConfirmationAddImageState());
  }

  FutureOr<void> _onImagePageChanged(event, emit) {
    if (state is BatchConfirmationInitial) {
      final state_ = state as BatchConfirmationInitial;

      emit(state_.copyWith(
        currentIndex: event.index,
        images: state_.images,
      ));
    }
  }

  FutureOr<void> _onImageRetaked(event, emit) {
    if (state is BatchConfirmationInitial) {
      final state_ = state as BatchConfirmationInitial;

      emit(state_.copyWith(
        currentIndex: state_.currentIndex,
        images: List.from(state_.images)
          ..replaceRange(
            state_.currentIndex,
            state_.currentIndex + 1,
            [event.imagePath],
          ),
      ));
    }
  }
}
