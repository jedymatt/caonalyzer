import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' show decodeImage;
import 'package:meta/meta.dart';

import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/services/detected_object_service.dart';
import 'package:caonalyzer/locator.dart';

part 'batch_insights_event.dart';
part 'batch_insights_state.dart';

class BatchInsightsBloc extends Bloc<BatchInsightsEvent, BatchInsightsState> {
  final service = locator.get<DetectedObjectService>();
  final _detector = ObjectDetectorConfig.mode.value.makeObjectDetector;

  BatchInsightsBloc() : super(BatchInsightsInitial()) {
    on<BatchInsightsStarted>((event, emit) async {
      emit(BatchInsightsInProgress());

      final List<List<DetectedObject>> imagesDetectedObjects = [];

      for (var image in event.images) {
        var detectedObjects = service.getAll(image);

        if (detectedObjects == null) {
          // detect objects
          final decodedImage = (decodeImage(File(image).readAsBytesSync()))!;

          final preprocessedImage = _detector.preprocessImage(decodedImage);

          try {
            detectedObjects = await _detector.runInference(preprocessedImage);
          } on ObjectDetectorInferenceException catch (e) {
            emit(BatchInsightsFailure(e.message));
            return;
          }

          service.putAll(
            image,
            detectedObjects,
          );
        }

        imagesDetectedObjects.add(detectedObjects);
      }

      var moldsCount = imagesDetectedObjects.map((e) => e.length).sum;

      var imagesConfidences = imagesDetectedObjects
          .map((e) => e.map((e_) => e_.confidence).sum)
          .sum;

      emit(BatchInsightsSuccess(
        imagesDetectedObjects: imagesDetectedObjects,
        moldsCount: moldsCount,
        averageMoldPerImage: imagesDetectedObjects.map((e) => e.length).sum /
            imagesDetectedObjects.length,
        averageOverallConfidence: imagesConfidences / moldsCount,
        moldsCountPerImage: imagesDetectedObjects.map((e) => e.length).toList(),
      ));
    });
  }

  @override
  Future<void> close() {
    _detector.dispose();
    return super.close();
  }
}
