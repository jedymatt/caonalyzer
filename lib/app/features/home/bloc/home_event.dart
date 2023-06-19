part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class HomeNavigateToCameraEvent extends HomeEvent {}

class HomeNavigateToSettingsEvent extends HomeEvent {}

class HomeChangeTabToGalleryEvent extends HomeEvent {}
