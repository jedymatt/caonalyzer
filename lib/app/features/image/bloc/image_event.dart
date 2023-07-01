part of 'image_bloc.dart';

@immutable
abstract class ImageEvent {}

class ImagePageChanged extends ImageEvent {
  final int index;
  ImagePageChanged({required this.index});
}

class ImageDetectionToggled extends ImageEvent {}

class ImageScaleChanged extends ImageEvent {
  final ImageScale scale;

  ImageScaleChanged({required this.scale});
}

class _ImageDetectionEnabled extends ImageEvent {}
