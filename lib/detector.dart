import 'dart:convert';
import 'dart:io';

import 'package:caonalyzer/object_detectors/enums/object_label.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
// import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'globals.dart';
import 'object_detectors/models/object_detection_output.dart';

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

List<int> reshapeImageBytes(List<int> imageBytes, int width, int height) {
  final reshapedBytes = List<int>.filled(width * height * 3, 0);

  final bytesPerPixel = 3; // Assuming RGB image
  final originalWidth = imageBytes.length ~/ (height * bytesPerPixel);
  final originalBytesPerPixel = imageBytes.length ~/ (width * height);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final originalX = (x * originalWidth) ~/ width;
      final originalY = (y * height) ~/ height;

      final originalPixelIndex =
          (originalY * originalWidth + originalX) * originalBytesPerPixel;
      final reshapedPixelIndex = (y * width + x) * bytesPerPixel;

      reshapedBytes[reshapedPixelIndex] = imageBytes[originalPixelIndex];
      reshapedBytes[reshapedPixelIndex + 1] =
          imageBytes[originalPixelIndex + 1];
      reshapedBytes[reshapedPixelIndex + 2] =
          imageBytes[originalPixelIndex + 2];
    }
  }

  return reshapedBytes;
}

Future<List<ObjectDetectionOutput>> runInference(img.Image image) async {
  // reshape to [1,?,?,3]
  ImageProcessor imageProcessor = ImageProcessorBuilder()
      .add(ResizeOp(640, 640, ResizeMethod.bilinear))
      // .add(NormalizeOp(0, 255))
      .build();
  // final inputTensor = imageProcessor.process(TensorImage.fromImage(image));

  TensorImage tensorImage = TensorImage.fromImage(image);
  tensorImage = imageProcessor
      .process(tensorImage); // remove this line to use the original image

  print(tensorImage.getDataType());

  final response = await http.post(
    Uri.parse('http://$host:8501/v1/models/faster_rcnn:predict'),
    headers: {
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'inputs': {
        'input_tensor': reshapeBytes(tensorImage.getBuffer().asUint8List(),
            tensorImage.width, tensorImage.height),
      }
    }),
  );

  if (response.statusCode != HttpStatus.ok) {
    print(response.body);
    throw Exception('Failed to run inference.');
  }

  if (kDebugMode) {
    print(jsonDecode(response.body)['outputs']['num_detections']);
    print(jsonDecode(response.body)['outputs']['detection_classes']);
  }

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
          image.width.toDouble(),
          image.height.toDouble(),
        ),
      );
    }
  }

  return outputs;
}
