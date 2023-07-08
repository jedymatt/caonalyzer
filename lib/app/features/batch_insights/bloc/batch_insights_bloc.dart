import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/detectors/tf_serving_object_detector.dart';
import 'package:caonalyzer/object_detectors/object_detection_output.dart';
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

  BatchInsightsBloc() : super(BatchInsightsInitial()) {
    on<BatchInsightsStarted>((event, emit) async {
      emit(BatchInsightsInProgress());

      final List<List<DetectedObject>> imagesDetectedObjects = [];

      for (var image in event.images) {
        var detectedObjects = service.getAll(image);

        if (detectedObjects == null) {
          // detect objects
          final objectDetector = ObjectDetectorConfig.mode.value.objectDetector;

          final decodedImage = (decodeImage(File(image).readAsBytesSync()))!;

          final preprocessedImage =
              objectDetector.preprocessImage(decodedImage);

          List<ObjectDetectionOutput> outputs = [];

          if (objectDetector is TfServingObjectDetector) {
            try {
              outputs = await objectDetector.runInference(preprocessedImage);

              detectedObjects = outputs
                  .map((e) => DetectedObject(
                        label: e.label,
                        confidence: e.confidence,
                        box: e.boundingBox.toLTRBList(),
                      ))
                  .toList();
            } catch (e) {
              emit(BatchInsightsFailure(
                  'Online mode failed, no network connection or server is down.'));

              return;
            }
          } else {
            outputs = await objectDetector.runInference(preprocessedImage);
          }

          detectedObjects = outputs
              .map((e) => DetectedObject(
                    label: e.label,
                    confidence: e.confidence,
                    box: e.boundingBox.toLTRBList(),
                  ))
              .toList();

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
}
