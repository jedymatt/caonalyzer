import 'package:path/path.dart' as path_lib;
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

  String get relativeDirPath => path_lib.basename(dirPath);

  @override
  String toString() {
    return 'Batch(title: $title, dirPath: $dirPath, images: $images)';
  }
}
