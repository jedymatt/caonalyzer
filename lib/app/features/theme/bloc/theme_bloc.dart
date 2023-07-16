import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/features/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box _box = Hive.box('settings');
  ThemeBloc({AppTheme? initialTheme})
      : super(ThemeState(initialTheme ?? AppTheme.lightPrimary)) {
    on<ThemeChanged>((event, emit) {
      _box.put('theme', event.theme.index);
      emit(ThemeState(event.theme));
    });
  }
}
