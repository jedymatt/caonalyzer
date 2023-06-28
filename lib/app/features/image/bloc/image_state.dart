part of 'image_bloc.dart';

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {
  final List<Image> images;
  final int index;
  final bool showDetection;
  final bool detectionInProgress;
  ImageInitial({
    required this.images,
    this.index = 0,
    this.showDetection = false,
    this.detectionInProgress = false,
  });

  ImageInitial copyWith({
    List<Image>? images,
    int? index,
    bool? showDetection,
    bool? detectionInProgress,
  }) {
    return ImageInitial(
      images: images ?? this.images,
      index: index ?? this.index,
      showDetection: showDetection ?? this.showDetection,
      detectionInProgress: detectionInProgress ?? this.detectionInProgress,
    );
  }
}
