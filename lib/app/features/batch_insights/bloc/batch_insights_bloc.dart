import 'package:bloc/bloc.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/gallery/metadata_reader.dart';
import 'package:caonalyzer/gallery/metadata_writer.dart';
import 'package:caonalyzer/gallery/models/image_metadata.dart';
import 'package:caonalyzer/globals.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image/image.dart' show decodeImageFile;
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

part 'batch_insights_event.dart';
part 'batch_insights_state.dart';

class BatchInsightsBloc extends Bloc<BatchInsightsEvent, BatchInsightsState> {
  BatchInsightsBloc() : super(BatchInsightsInitial()) {
    on<BatchInsightsStarted>((event, emit) async {
      emit(BatchInsightsInProgress());

      final List<List<DetectedObject>> imagesDetectedObjects = [];

      for (var image in event.images) {
        var imageMetadata = MetadataReader.read(image);

        if (imageMetadata == null) {
          // detect objects
          final box = await Hive.openBox<PreferredMode>(kSettingsBoxName);

          final preferredMode = box.get(
            'preferredMode',
            defaultValue: PreferredMode.offline,
          )!;

          final objectDetector = preferredMode.objectDetector;

          final decodeImage = (await decodeImageFile(image))!;

          final preprocessedImage = objectDetector.preprocessImage(decodeImage);

          final outputs = await objectDetector.runInference(preprocessedImage);

          imageMetadata = ImageMetadata(
            imagePath: image,
            objectDetectionMode: preferredMode.toString(),
            objectDetectionOutputs: outputs
                .map((e) => ObjectDetectionOutput(
                      class_: e.label,
                      confidence: e.confidence,
                      boxes: e.boundingBox.toLTRBList(),
                    ))
                .toList(),
          );

          MetadataWriter.create(image, imageMetadata);
        }

        imagesDetectedObjects.add(imageMetadata.objectDetectionOutputs
            .map((e) => DetectedObject(
                  label: e.class_,
                  confidence: e.confidence,
                  boundingBox: e.boxes,
                ))
            .toList());
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
