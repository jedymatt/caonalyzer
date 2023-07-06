part of 'image_bloc.dart';

enum ImageScale { none, zoomIn, zoomOut }

enum ImageDetectionStatus { none, inProgress, success, failure }

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {
  final List<Image> images;
  final int index;
  final bool showDetection;
  final ImageDetectionStatus detectionStatus;
  final ImageScale scale;

  ImageInitial({
    required this.images,
    this.index = 0,
    this.showDetection = false,
    this.detectionStatus = ImageDetectionStatus.none,
    this.scale = ImageScale.none,
  });

  ImageInitial copyWith({
    List<Image>? images,
    int? index,
    bool? showDetection,
    ImageDetectionStatus? detectionStatus,
    ImageScale? scale,
  }) {
    return ImageInitial(
      images: images ?? this.images,
      index: index ?? this.index,
      showDetection: showDetection ?? this.showDetection,
      detectionStatus: detectionStatus ?? this.detectionStatus,
      scale: scale ?? this.scale,
    );
  }
}
