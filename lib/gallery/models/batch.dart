class Batch {
  Batch({
    required this.title,
    required this.dirPath,
    required this.images,
  });

  final String title;
  final String dirPath;
  final List<String> images;

  String get thumbnail => images.first;
}
