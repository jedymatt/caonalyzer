part of 'gallery_bloc.dart';

@immutable
abstract class GalleryState {}

abstract class GalleryActionState extends GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GallerySuccess extends GalleryState {
  final List<Batch> batches;
  final bool refreshing;

  GallerySuccess({required this.batches, this.refreshing = false});

  GallerySuccess copyWith({
    List<Batch>? batches,
    bool? refreshing,
  }) {
    return GallerySuccess(
      batches: batches ?? this.batches,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}
