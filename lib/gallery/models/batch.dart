import 'picture.dart';

class Batch {
  final String title;
  final String path;
  final String date;
  final List<Picture> pictures;

  Batch({
    required this.title,
    required this.path,
    required this.date,
    required this.pictures,
  });
}
