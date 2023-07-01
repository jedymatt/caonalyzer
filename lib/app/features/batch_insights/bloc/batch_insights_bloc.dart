import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/services/detected_object_service.dart';

import 'package:caonalyzer/services.dart';
import 'package:image/image.dart' show decodeImageFile;
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

part 'batch_insights_event.dart';
part 'batch_insights_state.dart';

class BatchInsightsBloc extends Bloc<BatchInsightsEvent, BatchInsightsState> {
  final service = getIt.get<DetectedObjectService>();

  BatchInsightsBloc() : super(BatchInsightsInitial()) {
    on<BatchInsightsStarted>((event, emit) async {
      emit(BatchInsightsInProgress());

      final List<List<DetectedObject>> imagesDetectedObjects = [];

      for (var image in event.images) {
        var detectedObjects = service.getAll(image);

        if (detectedObjects == null) {
          // detect objects
          final objectDetector = ObjectDetectorConfig.mode.value.objectDetector;

          final decodeImage = (await decodeImageFile(image))!;

          final preprocessedImage = objectDetector.preprocessImage(decodeImage);

          final outputs = await objectDetector.runInference(preprocessedImage);

          detectedObjects = outputs
              .map((e) => DetectedObject(
                    label: e.label,
                    confidence: e.confidence,
                    boundingBox: e.boundingBox.toLTRBList(),
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
      ));
    });
  }
}
