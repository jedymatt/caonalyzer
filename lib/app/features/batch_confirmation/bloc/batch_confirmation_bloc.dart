import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';

part 'batch_confirmation_event.dart';

part 'batch_confirmation_state.dart';

class BatchConfirmationBloc
    extends Bloc<BatchConfirmationEvent, BatchConfirmationState> {
  BatchConfirmationBloc({required List<String> images})
      : super(BatchConfirmationInitial(images: images)) {
    on<BatchConfirmationAddImageEvent>((event, emit) {
      emit(BatchConfirmationAddImageState());
    });

    on<BatchConfirmationChangeImagePageEvent>((event, emit) {
      emit(BatchConfirmationInitial(
        currentIndex: event.index,
        images: event.images,
      ));
    });

    on<BatchConfirmationRetakeImageEvent>((event, emit) {
      emit(BatchConfirmationInitial(
        currentIndex: event.toRetakeImageIndex,
        images: List.from(event.images)
          ..replaceRange(
            event.toRetakeImageIndex,
            event.toRetakeImageIndex + 1,
            [event.retakedImagePath],
          ),
      ));
    });

    on<BatchConfirmationSaveBatchEvent>((event, emit) async {
      emit(BatchConfirmationLoadingSaveBatchState());

      // if batchPath is does not exist, create it
      if (!GalleryReader.batchExists(event.batchPath)) {
        GalleryWriter.createDirectory(event.batchPath);
      }

      await GalleryWriter.appendImages(event.images, event.batchPath);

      emit(BatchConfirmationNavigateToBatchPageActionState(
        batchPath: event.batchPath,
      ));
    });
  }
}
