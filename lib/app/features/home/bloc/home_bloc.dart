import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      emit(HomeInitial());
    });
    on<HomeNavigateToCameraEvent>((event, emit) {
      debugPrint('HomeNavigateToCameraEvent');
      emit(HomeNavigateToCameraActionState());
    });
    on<HomeNavigateToSettingsEvent>((event, emit) {
      debugPrint('HomeNavigateToSettingsEvent');
      emit(HomeNavigateToSettingsActionState());
    });
    on<HomeChangeTabToGalleryEvent>((event, emit) {
      debugPrint('HomeChangeTabToGalleryEvent');
      emit(HomeTabChangedToGallery());
    });
  }
}
