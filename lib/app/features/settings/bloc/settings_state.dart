part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoadInProgress extends SettingsState {}

class SettingsLoadSuccess extends SettingsState {
  final PreferredMode preferredMode;
  final String host;
  final String port;

  SettingsLoadSuccess({
    required this.preferredMode,
    required this.host,
    required this.port,
  });

  SettingsLoadSuccess copyWith({
    PreferredMode? preferredMode,
    String? host,
    String? port,
  }) {
    return SettingsLoadSuccess(
      preferredMode: preferredMode ?? this.preferredMode,
      host: host ?? this.host,
      port: port ?? this.port,
    );
  }
}
