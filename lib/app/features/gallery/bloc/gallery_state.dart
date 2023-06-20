part of 'gallery_bloc.dart';

@immutable
abstract class GalleryState {}

abstract class GalleryActionState extends GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<Batch> batches;

  GalleryLoaded({required this.batches});
}
