part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent {}

class ThemeLoaded extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final AppTheme theme;

  ThemeChanged(this.theme);
}
