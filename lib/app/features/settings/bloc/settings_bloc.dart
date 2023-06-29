import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/configs/object_detector_config.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
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
    ObjectDetectorConfig.ipAddress.save('${state_.host}:${state_.port}');
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
    ObjectDetectorConfig.mode.save(state_.preferredMode);
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
    final PreferredMode preferredMode = ObjectDetectorConfig.mode.value;

    final hostAndPort = ObjectDetectorConfig.ipAddress.value.split(':');

    emit(SettingsLoadSuccess(
      preferredMode: preferredMode,
      host: hostAndPort[0],
      port: hostAndPort[1],
    ));
  }
}
