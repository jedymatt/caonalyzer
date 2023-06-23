part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeTabChangedEvent extends HomeEvent {
  final HomeTab tab;

  HomeTabChangedEvent({
    required this.tab,
  });
}
