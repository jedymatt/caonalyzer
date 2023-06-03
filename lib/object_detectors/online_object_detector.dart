import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/globals.dart';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

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
        'Error running inference HTTP request. See logs for details.',
      );
    }

    return ObjectDetectionOutput.fromMap(Map.from(jsonDecode(response.body)));
  }
}
