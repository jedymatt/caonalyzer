import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';

part 'batch_confirmation_event.dart';

part 'batch_confirmation_state.dart';

class BatchConfirmationBloc
    extends Bloc<BatchConfirmationEvent, BatchConfirmationState> {
  BatchConfirmationBloc() : super(BatchConfirmationInitial()) {
    on<BatchConfirmationAddImageEvent>((event, emit) {
      emit(BatchConfirmationAddImageState());
    });

    on<BatchConfirmationRetakeImageEvent>((event, emit) {
      emit(BatchConfirmationRetakeImageState());
    });

    on<BatchConfirmationSaveBatchEvent>((event, emit) async {
      emit(BatchConfirmationLoadingSaveBatchState());

      // if batchPath is does not exist, create it
      if (!GalleryReader.batchExists(event.batchPath)) {
        GalleryWriter.createDirectory(event.batchPath);
      }

      await GalleryWriter.appendImages(event.images, event.batchPath);

      emit(BatchConfirmationNavigateToBatchPageActionState(
          batchPath: event.batchPath));
    });
  }
}
