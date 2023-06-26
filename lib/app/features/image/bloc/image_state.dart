part of 'image_bloc.dart';

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {
  final List<String> images;
  final int index;
  ImageInitial({required this.images, this.index = 0});

  ImageInitial copyWith({
    List<String>? images,
    int? index,
  }) {
    return ImageInitial(
      images: images ?? this.images,
      index: index ?? this.index,
    );
  }
}
