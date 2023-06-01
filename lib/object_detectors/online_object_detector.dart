import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/box_converter.dart';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

import './enums/object_label.dart';
import './object_detectors.dart';

class OnlineObjectDetector extends ObjectDetector {
  @override
  Future<ObjectDetectionOutput> runInference(TensorImage tensorImage) async {
    List reshaped = tensorImage
        .getBuffer()
        .asUint8List()
        .reshape([1, tensorImage.height, tensorImage.width, 3]);

    final response = await http.post(
      Uri.parse('http://${host.value}:8501/v1/models/faster_rcnn:predict'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'inputs': {'input_tensor': reshaped}
      }),
    );

    if (response.statusCode != HttpStatus.ok) {
      log(jsonDecode(response.body)['message']);

      throw Exception(
          'Error running inference HTTP request. See logs for details.');
    }

    final Map<String, dynamic> result = Map.from(jsonDecode(response.body));

    return ObjectDetectionOutput.fromMap(result['outputs']);
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
