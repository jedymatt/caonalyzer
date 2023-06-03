import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:image/image.dart'
    show ChannelOrder, Image, Interpolation, copyResize, encodeBmp;
import 'package:pytorch_lite/pigeon.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class PytorchObjectDetector implements ObjectDetector {
  ModelObjectDetection? _model;

  @override
  Image preProcessImage(Image image) {
    if (image.width <= 640 || image.height <= 640) {
      return image;
    }

    if (image.width > image.height) {
      image = copyResize(
        image,
        width: 640,
        interpolation: Interpolation.linear,
      );
    } else {
      image = copyResize(
        image,
        height: 640,
        interpolation: Interpolation.linear,
      );
    }

    return image;
  }

  @override
  Future<List<ObjectDetectionOutput>> runInference(Image image) async {
    final model = await getModel();

    final results = await model.getImagePrediction(encodeBmp(image));

    return results
        .map((e) => ObjectDetectionOutput(
              e!.className ?? e.classIndex.toString(),
              e.score,
              BoundingBox(
                left: e.rect.left,
                top: e.rect.top,
                right: e.rect.right,
                bottom: e.rect.bottom,
              ),
            ))
        .toList();
  }

  Future<ModelObjectDetection> getModel() async {
    _model ??= await PytorchLite.loadObjectDetectionModel(
      'assets/yolov8n.torchscript.pt',
      1,
      640,
      640,
      objectDetectionModelType: ObjectDetectionModelType.yolov8,
      labelPath: 'assets/labels.txt',
    );

    return _model!;
  }
}
