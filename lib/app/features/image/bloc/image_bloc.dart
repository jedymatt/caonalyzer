import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/configs/object_detector_config.dart';
import 'package:caonalyzer/app/features/image/models/image.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:caonalyzer/gallery/metadata_writer.dart';
import 'package:caonalyzer/gallery/models/image_metadata.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart' show PageController;
import 'package:hive_flutter/adapters.dart';
import 'package:image/image.dart' hide Image;
import 'package:meta/meta.dart';
import 'package:caonalyzer/app/data/models/models.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PageController _pageController;
  final List<Image> _images;

  ImageBloc({required List<Image> images, int initialIndex = 0})
      : _images = List.from(images),
        _pageController = PageController(initialPage: initialIndex),
        super(ImageInitial(images: images, index: initialIndex)) {
    on<ImagePageChanged>((event, emit) async {
      ImageState state_ = state;

      if (state_ is! ImageInitial) return;

      emit(state_ = state_.copyWith(index: event.index));

      if (state_.showDetection) {
        // todo: display preview
        var currentImage = state_.images[event.index];

        if (!MetadataReader.exists(currentImage.path)) {
          emit(state_.copyWith(detectionInProgress: true));

          final box = await Hive.openBox(kSettingsBoxName);

          final PreferredMode mode = box.get(
            'preferredMode',
            defaultValue: PreferredMode.offline,
          )!;

          final objectDetector = mode.objectDetector;

          final decodedImage = (await decodeImageFile(currentImage.path))!;
          final preprocessImage = objectDetector.preprocessImage(decodedImage);

          final detections = await objectDetector.runInference(preprocessImage);

          final imageMetadata = ImageMetadata(
            imagePath: currentImage.path,
            objectDetectionMode: mode.toString(),
            objectDetectionOutputs: detections
                .map((e) => ObjectDetectionOutput(
                      class_: e.label,
                      confidence: e.confidence,
                      boxes: e.boundingBox.toLTRBList(),
                    ))
                .toList(),
          );

          MetadataWriter.create(
            currentImage.path,
            imageMetadata,
          );
        }

        emit(state_.copyWith(
          index: event.index,
          detectionInProgress: false,
          images: List.from(state_.images)
            ..replaceRange(
              event.index,
              event.index + 1,
              [
                currentImage.copyWith(
                  detectedObjects: MetadataReader.read(currentImage.path)!
                      .objectDetectionOutputs
                      .map((e) => DetectedObject(
                            label: e.class_,
                            confidence: e.confidence,
                            boundingBox: e.boxes,
                          ))
                      .toList(),
                ),
              ],
            ),
        ));
      }
    });

    on<ImageDetectionToggled>((event, emit) async {
      ImageState state_ = state;

      if (state_ is! ImageInitial) return;
      state_ = state_.copyWith(showDetection: !state_.showDetection);

      emit(state_);

      if (!state_.showDetection) {
        emit(state_.copyWith(images: List.from(_images)));
        return;
      }

      final currentImage = state_.images[state_.index];

      if (MetadataReader.exists(currentImage.path)) {
        emit(state_.copyWith(
          images: List.from(state_.images)
            ..replaceRange(
              state_.index,
              state_.index + 1,
              [
                currentImage.copyWith(
                  detectedObjects: MetadataReader.read(currentImage.path)!
                      .objectDetectionOutputs
                      .map((e) => DetectedObject(
                            label: e.class_,
                            confidence: e.confidence,
                            boundingBox: e.boxes,
                          ))
                      .toList(),
                ),
              ],
            ),
        ));
        return;
      }
      // check if preview exists

      // if not, run inference and save metadata and preview

      emit(state_.copyWith(detectionInProgress: true));

      final objectDetector = ObjectDetectorConfig.mode.objectDetector;

      final decodedImage =
          (await decodeImageFile(state_.images[state_.index].path))!;
      final preproccessImage = objectDetector.preprocessImage(decodedImage);

      final detections = await objectDetector.runInference(preproccessImage);

      final imageMetadata = ImageMetadata(
        imagePath: currentImage.path,
        objectDetectionMode: ObjectDetectorConfig.mode.toString(),
        objectDetectionOutputs: detections
            .map((e) => ObjectDetectionOutput(
                  class_: e.label,
                  confidence: e.confidence,
                  boxes: e.boundingBox.toLTRBList(),
                ))
            .toList(),
      );

      MetadataWriter.create(
        currentImage.path,
        imageMetadata,
      );

      emit(state_.copyWith(
        detectionInProgress: false,
        images: List.from(state_.images)
          ..replaceRange(state_.index, state_.index + 1, [
            currentImage.copyWith(
              detectedObjects: detections
                  .map((e) => DetectedObject(
                        label: e.label,
                        confidence: e.confidence,
                        boundingBox: e.boundingBox.toLTRBList(),
                      ))
                  .toList(),
            )
          ]),
      ));
    });
  }

  PageController get controller => _pageController;

  @override
  Future<void> close() {
    _pageController.dispose();
    return super.close();
  }
}
