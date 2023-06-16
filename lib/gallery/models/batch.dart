import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path_lib;

class Batch {
  Batch({
    required this.title,
    required this.dirPath,
  });

  final String title;
  final String dirPath;

  String get relativeDirPath => path_lib.basename(dirPath);

  String get thumbnail => Glob(
        path_lib.join(
          dirPath.replaceAllMapped(
            RegExp(r'([\\^$*+?{}\[\]().])'),
            (match) => '\\${match.group(1)}',
          ),
          '*.{jpg,jpeg,png}',
        ),
      ).listSync().first.path;

  List<String> get images => Glob(
        path_lib.join(
          dirPath.replaceAllMapped(
            RegExp(r'([\\^$*+?{}\[\]().])'),
            (match) => '\\${match.group(1)}',
          ),
          '*.{jpg,jpeg,png}',
        ),
      ).listSync().map((e) => e.path).toList();

  @override
  String toString() {
    return 'Batch(title: $title, dirPath: $dirPath)';
  }

  Batch copyWith({
    String? title,
    String? dirPath,
    String? thumbnail,
  }) {
    return Batch(
      title: title ?? this.title,
      dirPath: dirPath ?? this.dirPath,
    );
  }
}
