import 'package:bloc/bloc.dart';
import 'package:caonalyzer/gallery/gallery_reader.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_lib;

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
          selectedImages: event.selectedImages.toSet().toList()));
    });

    on<BatchCancelSelectionModeEvent>((event, emit) {
      emit(BatchSuccessfulFetchImages(images: event.images));
    });

    on<BatchDeleteImagesEvent>((event, emit) async {
      emit(BatchDeletingImagesState());
      GalleryWriter.removeImages(event.images);
      final batchPath = path_lib.dirname(event.images.first);

      final remainingImages = (await GalleryReader.getImages(batchPath))
          .map((e) => e.path)
          .toList();

      if (remainingImages.isEmpty) {
        GalleryWriter.deleteDirectory(batchPath);
        emit(BatchNavigateToParentPageActionState());
        return;
      }

      emit(BatchSuccessfulFetchImages(
        images: remainingImages,
      ));

      if (remainingImages.isEmpty) {
        GalleryWriter.deleteDirectory(batchPath);
        emit(BatchNavigateToParentPageActionState());
      }
    });
  }
}
