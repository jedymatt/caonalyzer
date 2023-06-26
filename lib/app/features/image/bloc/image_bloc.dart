import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PageController _pageController;

  ImageBloc({required List<String> images, int initialIndex = 0})
      : _pageController = PageController(initialPage: initialIndex),
        super(ImageInitial(images: images, index: initialIndex)) {
    on<ImagePageChanged>((event, emit) {
      final state_ = state;

      if (state_ is! ImageInitial) return null;

      emit(state_.copyWith(index: event.index));
    });
  }

  PageController get controller => _pageController;

  @override
  Future<void> close() {
    _pageController.dispose();
    return super.close();
  }
}
