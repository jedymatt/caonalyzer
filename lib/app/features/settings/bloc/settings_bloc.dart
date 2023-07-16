import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:caonalyzer/app/data/utils/object_detector_settings.dart';
import 'package:caonalyzer/locator.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ObjectDetectorSettings _objectDetectorSettings =
      locator.get<ObjectDetectorSettings>();

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

    _objectDetectorSettings.serverHost = '${state_.host}:${state_.port}';
    _objectDetectorSettings.save();
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
    _objectDetectorSettings.preferredMode = state_.preferredMode;
    _objectDetectorSettings.save();
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
    final serverHost = _objectDetectorSettings.serverHost.split(':');

    emit(SettingsLoadSuccess(
      preferredMode: _objectDetectorSettings.preferredMode,
      host: serverHost[0],
      port: serverHost.length > 1 ? serverHost[1] : '8501',
    ));
  }
}
