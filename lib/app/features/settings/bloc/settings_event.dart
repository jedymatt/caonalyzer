part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsStarted extends SettingsEvent {}

class SettingsPreferredModeChanged extends SettingsEvent {
  final PreferredMode preferredMode;

  SettingsPreferredModeChanged(this.preferredMode);
}

class SettingsPreferredModeSubmitted extends SettingsEvent {}

class SettingsServerHostChanged extends SettingsEvent {
  final String host;

  SettingsServerHostChanged(this.host);
}

class SettingsServerPortChanged extends SettingsEvent {
  final String port;

  SettingsServerPortChanged(this.port);
}

class SettingsServerSubmitted extends SettingsEvent {}
