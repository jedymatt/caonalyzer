part of 'gallery_bloc.dart';

@immutable
abstract class GalleryEvent {}

class GalleryStarted extends GalleryEvent {}

class GalleryImagesRefreshed extends GalleryEvent {}
