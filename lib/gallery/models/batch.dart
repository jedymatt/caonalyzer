import 'picture.dart';

class Batch {
  Batch({
    required this.title,
    required this.path,
    required this.date,
    required this.pictures,
  });

  final String title;
  final String path;
  final String date;
  final List<Picture> pictures;

  String? get thumbnail => pictures.elementAtOrNull(0)?.path;
}
