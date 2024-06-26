import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/app/data/utils/object_detector_settings.dart';
import 'package:caonalyzer/app/features/image/models/image.dart';
import 'package:caonalyzer/locator.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:flutter/material.dart' show PageController;
import 'package:image/image.dart' hide Image;
import 'package:meta/meta.dart';
import 'package:caonalyzer/app/data/models/models.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PageController _pageController;
  final List<Image> _initialImages;
  final DetectedObjectService service = locator.get<DetectedObjectService>();
  final ObjectDetector<DetectedObject> _detector =
      locator.get<ObjectDetectorSettings>().preferredMode.makeObjectDetector;

  ImageBloc({required List<Image> images, int initialIndex = 0})
      : _initialImages = List.from(images),
        _pageController = PageController(initialPage: initialIndex),
        super(ImageInitial(images: images, index: initialIndex)) {
    on<ImagePageChanged>(_onPageChanged);
    on<ImageDetectionToggled>(_onDetectionToggled);
    on<ImageScaleChanged>(_onImageScaleChanged);
    on<_ImageDetectionEnabled>(_onImageDetectionEnabled);
  }

  FutureOr<void> _onImageScaleChanged(
      ImageScaleChanged event, Emitter<ImageState> emit) {
    var state_ = state;

    if (state_ is! ImageInitial) return null;

    emit(state_.copyWith(scale: event.scale));
  }

  FutureOr<void> _onDetectionToggled(
      ImageDetectionToggled event, Emitter<ImageState> emit) async {
    final state_ = state;

    if (state_ is! ImageInitial) return;

    if (state_.showDetection) {
      emit(state_.copyWith(
        images: List.from(_initialImages),
        detectionStatus: ImageDetectionStatus.none,
        showDetection: false,
      ));
      return;
    } else {
      add(_ImageDetectionEnabled());
    }
  }

  FutureOr<void> _onPageChanged(
      ImagePageChanged event, Emitter<ImageState> emit) async {
    ImageState state_ = state;

    if (state_ is! ImageInitial) return;

    emit(state_ = state_.copyWith(index: event.index));

    if (state_.showDetection) {
      add(_ImageDetectionEnabled());
    }
  }

  PageController get controller => _pageController;

  @override
  Future<void> close() {
    _pageController.dispose();
    _detector.dispose();
    return super.close();
  }

  FutureOr<void> _onImageDetectionEnabled(
      _ImageDetectionEnabled event, Emitter<ImageState> emit) async {
    final state_ = state;

    if (state_ is! ImageInitial) return;

    final currentImage = state_.images[state_.index];

    // check if detection result is already saved
    if (currentImage.detectedObjects != null) return;

    emit(state_.copyWith(
      detectionStatus: ImageDetectionStatus.inProgress,
    ));

    var detectedObjects = service.getAll(currentImage.path);

    if (detectedObjects != null) {
      emit(state_.copyWith(
        showDetection: true,
        detectionStatus: ImageDetectionStatus.success,
        images: List.from(state_.images)
          ..replaceRange(
            state_.index,
            state_.index + 1,
            [
              currentImage.copyWith(
                detectedObjects: List.from(detectedObjects),
              ),
            ],
          ),
      ));
      return;
    }
    // if not, run inference and save result
    emit(state_.copyWith(
      showDetection: true,
      detectionStatus: ImageDetectionStatus.inProgress,
    ));

    final decodedImage = decodeJpg(
      File(state_.images[state_.index].path).readAsBytesSync(),
    )!;
    final preprocessedImage = _detector.preprocessImage(decodedImage);

    if (_detector is TfServingObjectDetector) {
      try {
        detectedObjects = await _detector.runInference(preprocessedImage);
      } catch (e) {
        emit(state_.copyWith(
          showDetection: true,
          detectionStatus: ImageDetectionStatus.failure,
        ));
        return;
      }
    } else {
      detectedObjects = await _detector.runInference(preprocessedImage);
    }

    service.putAll(
      currentImage.path,
      detectedObjects,
    );

    emit(state_.copyWith(
      showDetection: true,
      detectionStatus: ImageDetectionStatus.success,
      images: List.from(state_.images)
        ..replaceRange(state_.index, state_.index + 1, [
          currentImage.copyWith(
            detectedObjects: List.from(detectedObjects),
          )
        ]),
    ));
  }
}
