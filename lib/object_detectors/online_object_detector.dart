import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/object_detectors/enums/object_label.dart';
import 'package:caonalyzer/object_detectors/object_detector.dart';
import 'package:caonalyzer/object_detectors/models/object_detection_output.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

import 'package:caonalyzer/globals.dart';

class OnlineObjectDetector implements ObjectDetector {
  @override
  Future<List<ObjectDetectionOutput>> runInference(
      TensorImage tensorImage) async {
    final response = await http.post(
      Uri.parse('http://$host:8501/v1/models/faster_rcnn:predict'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'inputs': {
          'input_tensor': reshapeBytes(
            tensorImage.getBuffer().asUint8List(),
            tensorImage.width,
            tensorImage.height,
          ),
        }
      }),
    );

    if (response.statusCode != HttpStatus.ok) {
      log(jsonDecode(response.body)['message']);

      throw Exception(
          'Error running inference HTTP request. See logs for details.');
    }

    log(jsonDecode(response.body)['outputs']['num_detections']);
    log(jsonDecode(response.body)['outputs']['detection_classes']);

    final Map<String, dynamic> result = Map.from(jsonDecode(response.body));

    final List detections = result['outputs']['detection_boxes'][0];
    final List labels = result['outputs']['detection_classes'][0];
    final List scores = result['outputs']['detection_scores'][0];

    List<ObjectDetectionOutput> outputs = [];

    for (int i = 0; i < detections.length; i++) {
      if (scores[i] > 0.5) {
        outputs.add(
          ObjectDetectionOutput(
            ObjectLabel.from(labels[i]).toString(),
            scores[i],
            detections[i][1],
            detections[i][0],
            tensorImage.width.toDouble(),
            tensorImage.height.toDouble(),
          ),
        );
      }
    }

    return outputs;
  }

  @override
  TensorImage preProcessImage(img.Image image) {
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(640, 640, ResizeMethod.bilinear))
        .build();

    TensorImage tensorImage = TensorImage.fromImage(image);

    // remove this if it will break the code
    return imageProcessor.process(tensorImage);
  }

  List<List<List<List<int>>>> reshapeBytes(
      List<int> bytes, int width, int height) {
    List<List<List<List<int>>>> reshapedArray = List.generate(
      1,
      (_) => List.generate(
        height,
        (_) => List.generate(width, (_) => List.generate(3, (_) => 0)),
      ),
    );

    int index = 0;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        for (int k = 0; k < 3; k++) {
          reshapedArray[0][i][j][k] = bytes[index];
          index++;
        }
      }
    }

    return reshapedArray;
  }
}
