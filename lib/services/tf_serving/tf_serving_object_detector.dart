import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/globals.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:image/image.dart'
    show ChannelOrder, Image, Interpolation, copyResize;

import 'object_detection_response.dart';

class TfServingObjectDetector implements ObjectDetector {
  @override
  Image preProcessImage(Image image) {
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
    final reshaped = image
        .getBytes(order: ChannelOrder.rgb)
        .reshape([1, image.height, image.width, 3]);

    final uri =
        Uri.parse('http://${host.value}:8501/v1/models/faster_rcnn:predict');

    final response = await http.post(
      uri,
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

    final output = ObjectDetectionResponse.fromJson(response.body);

    return output.toObjectDetectionOutputs();
  }
}
