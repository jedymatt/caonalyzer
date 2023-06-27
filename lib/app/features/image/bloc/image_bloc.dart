import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:caonalyzer/gallery/metadata_writer.dart';
import 'package:caonalyzer/gallery/models/image_metadata.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_lib;

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

    on<ImageDetectionToggled>((event, emit) async {
      ImageState state_ = state;

      if (state_ is! ImageInitial) return;
      state_ = state_.copyWith(showDetection: !state_.showDetection);

      emit(state_);

      if (!state_.showDetection) return;

      final currentImagePath = state_.images[state_.index];

      final previewExists = File(
        '${path_lib.withoutExtension(currentImagePath)}.preview${path_lib.extension(currentImagePath)}',
      ).existsSync();

      // check if metadata exists and preview does not exist
      if (MetadataReader.exists(currentImagePath) && !previewExists) {
        // create preview
        return;
      }

      if (MetadataReader.exists(currentImagePath) && previewExists) {
        // load preview
        return;
      }
      // check if preview exists

      // if not, run inference and save metadata and preview

      emit(state_.copyWith(detectionInProgress: true));

      final box = await Hive.openBox(kSettingsBoxName);

      final PreferredMode mode = box.get(
        'preferredMode',
        defaultValue: PreferredMode.offline,
      )!;

      final objectDetector = mode.objectDetector;

      final decodedImage =
          (await decodeImageFile(state_.images[state_.index]))!;
      final preproccessImage = objectDetector.preprocessImage(decodedImage);

      final detections = await objectDetector.runInference(preproccessImage);

      final previewImage = decodedImage.clone();

      for (var detected in detections) {
        final absoluteBoundingBox = detected.boundingBox
            .toPixel(previewImage.height, previewImage.width);
        drawRect(
          previewImage,
          x1: absoluteBoundingBox.left.toInt(),
          y1: absoluteBoundingBox.top.toInt(),
          x2: absoluteBoundingBox.right.toInt(),
          y2: absoluteBoundingBox.bottom.toInt(),
          color: ColorRgb8(255, 0, 0),
        );
      }

      MetadataWriter.create(
        currentImagePath,
        ImageMetadata(
          imagePath: currentImagePath,
          objectDetectionMode: mode.toString(),
          objectDetectionOutputs: detections
              .map((e) => ObjectDetectionOutput(
                    class_: e.label,
                    confidence: e.confidence,
                    boxes: e.boundingBox.toLTRBList(),
                  ))
              .toList(),
        ),
      );

      final fileExtenstion = path_lib.extension(currentImagePath);
      // path lib get filename without extension
      final pathWithoutExtension = path_lib.withoutExtension(currentImagePath);

      File('$pathWithoutExtension.preview$fileExtenstion')
          .writeAsBytesSync(encodeJpg(previewImage));

      emit(state_.copyWith(detectionInProgress: false));
    });
  }

  PageController get controller => _pageController;

  @override
  Future<void> close() {
    _pageController.dispose();
    return super.close();
  }
}
