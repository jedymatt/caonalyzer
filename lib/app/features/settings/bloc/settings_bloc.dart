import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/globals.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late Box _box;

  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsPreferredModeChanged>(_onPreferredModeChanged);
    on<SettingsPreferredModeSubmitted>(_onPreferredModeSubmitted);
    on<SettingsServerHostChanged>(_onServerHostChanged);
    on<SettingsServerPortChanged>(_onServerPortChanged);
    on<SettingsServerSubmitted>(_onServerSubmitted);
  }

  FutureOr<void> _onServerSubmitted(event, emit) {
    final state_ = state;
    if (state_ is! SettingsLoadSuccess) return null;
    _box.put('host', state_.host);
    _box.put('port', state_.port);
  }

  FutureOr<void> _onServerPortChanged(event, emit) {
    final state_ = state;
    if (state_ is! SettingsLoadSuccess) return null;
    emit(state_.copyWith(
      port: event.port,
    ));
  }

  FutureOr<void> _onServerHostChanged(event, emit) {
    final state_ = state;
    if (state_ is! SettingsLoadSuccess) return null;
    emit(state_.copyWith(
      host: event.host,
    ));
  }

  FutureOr<void> _onPreferredModeSubmitted(
      SettingsPreferredModeSubmitted event, emit) async {
    final state_ = state;
    if (state_ is! SettingsLoadSuccess) return;
    _box.put('preferredMode', state_.preferredMode.index);
  }

  FutureOr<void> _onPreferredModeChanged(
      SettingsPreferredModeChanged event, emit) async {
    final state_ = state;
    if (state_ is! SettingsLoadSuccess) return;
    emit(state_.copyWith(
      preferredMode: event.preferredMode,
    ));
  }

  FutureOr<void> _onStarted(SettingsStarted event, emit) async {
    emit(SettingsLoadInProgress());
    _box = await Hive.openBox(kSettingsBoxName);

    final int preferredModeIndex =
        _box.get('preferredMode', defaultValue: PreferredMode.offline.index);

    final String host = _box.get('host', defaultValue: '192.168.1.8');
    final String port = _box.get('port', defaultValue: '8000');

    emit(SettingsLoadSuccess(
      preferredMode: PreferredMode.values[preferredModeIndex],
      host: host,
      port: port,
    ));
  }
}