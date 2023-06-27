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
  final List<String> _images;

  ImageBloc({required List<String> images, int initialIndex = 0})
      : _images = List.from(images),
        _pageController = PageController(initialPage: initialIndex),
        super(ImageInitial(images: images, index: initialIndex)) {
    on<ImagePageChanged>((event, emit) {
      final state_ = state;

      if (state_ is! ImageInitial) return null;

      if (state_.showDetection) {
        // todo: display preview
      }

      emit(state_.copyWith(index: event.index));
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
        emit(state_.copyWith(
          images: List.from(state_.images)
            ..replaceRange(
              state_.index,
              state_.index + 1,
              [
                '${path_lib.withoutExtension(currentImagePath)}.preview${path_lib.extension(currentImagePath)}',
              ],
            ),
        ));
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
        final boxes = detected.boundingBox
            .toPixel(previewImage.height, previewImage.width)
            .toLTRBList()
            .map((e) => e.toInt())
            .toList();
        drawRect(
          previewImage,
          x1: boxes[0],
          y1: boxes[1],
          x2: boxes[2],
          y2: boxes[3],
          color: ColorRgb8(255, 0, 0),
        );

        drawString(
          previewImage,
          '${detected.label} ${(detected.confidence * 100).toStringAsFixed(2)}%',
          font: arial14,
          x: boxes[0],
          y: boxes[1],
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

      emit(state_.copyWith(
        detectionInProgress: false,
        images: List.from(state_.images)
          ..replaceRange(state_.index, state_.index + 1,
              ['$pathWithoutExtension.preview$fileExtenstion']),
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
