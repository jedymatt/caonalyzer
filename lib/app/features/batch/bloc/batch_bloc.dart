import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:meta/meta.dart';

part 'batch_event.dart';

part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  BatchBloc() : super(BatchInitial()) {
    on<BatchFetchImagesEvent>((event, emit) async {
      emit(BatchLoadingFetchImages());

      final images = await GalleryReader.getImages(event.batchPath);

      emit(BatchSuccessfulFetchImages(
        images: images.map((e) => e.path).toList(),
      ));
    });

    on<BatchSelectMultipleImagesEvent>((event, emit) {
      emit(BatchSelectionModeState(
        images: event.images,
        selectedImages: event.selectedImages.toSet().toList()
      ));
    });

    on<BatchCancelSelectionModeEvent>((event, emit) {
      emit(BatchSuccessfulFetchImages(images: event.images));
    });
  }
}
