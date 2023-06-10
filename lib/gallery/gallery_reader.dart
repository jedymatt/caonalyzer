import 'dart:io';

import 'models/batch.dart';

abstract class Reader {
  List<Batch> readBatches(String path);
  List<String> readImages(String path);
}