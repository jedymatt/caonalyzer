part of 'home_bloc.dart';

enum HomeTab { home, gallery }

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {
  final HomeTab tab;

  HomeInitial({
    this.tab = HomeTab.home,
  });
}
