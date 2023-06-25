import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';

part 'batch_confirmation_event.dart';
part 'batch_confirmation_state.dart';

class BatchConfirmationBloc
    extends Bloc<BatchConfirmationEvent, BatchConfirmationState> {
  BatchConfirmationBloc() : super(BatchConfirmationInitial()) {
    on<BatchConfirmationStarted>(_onStarted);
    on<BatchConfirmationImageAdded>(_onImageAdded);
    on<BatchConfirmationImagePageChanged>(_onImagePageChanged);
    on<BatchConfirmationImageRetaked>(_onImageRetaked);
    on<BatchConfirmationBatchSaved>(_onBatchSaved);
  }

  FutureOr<void> _onStarted(BatchConfirmationStarted event,
      Emitter<BatchConfirmationState> emit) async {
    if (state is! BatchConfirmationInitial) return null;

    final batchPath = event.batchPath ??
        await GalleryWriter.generateBatchPath(DateTime.now());

    final state_ = state as BatchConfirmationInitial;

    emit(state_.copyWith(
      currentIndex: 0,
      images: state_.images,
      batchPath: batchPath,
    ));
  }

  FutureOr<void> _onBatchSaved(BatchConfirmationBatchSaved event,
      Emitter<BatchConfirmationState> emit) async {
    if (state is! BatchConfirmationInitial) return null;

    final state_ = state as BatchConfirmationInitial;

    emit(BatchConfirmationLoadingSaveBatchState());

    // if batchPath is does not exist, create it
    if (!GalleryReader.batchExists(state_.batchPath!)) {
      GalleryWriter.createDirectory(state_.batchPath!);
    }

    await GalleryWriter.appendImages(state_.images, state_.batchPath!);

    emit(BatchConfirmationNavigateToBatchPageActionState(
      batchPath: state_.batchPath!,
    ));
  }

  FutureOr<void> _onImageAdded(
      BatchConfirmationImageAdded event, Emitter<BatchConfirmationState> emit) {
    if (state is BatchConfirmationInitial) {
      final state_ = state as BatchConfirmationInitial;

      emit(state_.copyWith(
        currentIndex: state_.currentIndex,
        images: List.from(state_.images)..add(event.imagePath),
      ));
    }
  }

  FutureOr<void> _onImagePageChanged(BatchConfirmationImagePageChanged event,
      Emitter<BatchConfirmationState> emit) {
    if (state is! BatchConfirmationInitial) return null;

    final state_ = state as BatchConfirmationInitial;

    emit(state_.copyWith(
      currentIndex: event.index,
      images: state_.images,
    ));
  }

  FutureOr<void> _onImageRetaked(BatchConfirmationImageRetaked event,
      Emitter<BatchConfirmationState> emit) {
    if (state is! BatchConfirmationInitial) return null;

    final state_ = state as BatchConfirmationInitial;

    List<String> images = List.from(state_.images);
    images[state_.currentIndex] = event.imagePath;
    emit(state_.copyWith(
      currentIndex: state_.currentIndex,
      images: images,
    ));
  }
}
