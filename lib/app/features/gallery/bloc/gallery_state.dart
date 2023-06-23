part of 'gallery_bloc.dart';

@immutable
abstract class GalleryState {}

abstract class GalleryActionState extends GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GallerySuccess extends GalleryState {
  final List<Batch> batches;

  GallerySuccess({required this.batches});
}

class GalleryRefreshingBatches extends GalleryState {
  final List<Batch> batches;

  GalleryRefreshingBatches({
    required this.batches,
  });
}
