import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:hive_flutter/adapters.dart';

class PreferredModeAdapter extends TypeAdapter<PreferredMode> {
  @override
  final int typeId = 1;

  @override
  PreferredMode read(BinaryReader reader) {
    final mode = reader.readByte();

    switch (mode) {
      case 0:
        return PreferredMode.offline;
      case 1:
        return PreferredMode.online;
      default:
        return PreferredMode.offline;
    }
  }

  @override
  void write(BinaryWriter writer, PreferredMode obj) {
    switch (obj) {
      case PreferredMode.offline:
        writer.writeByte(0);
      case PreferredMode.online:
        writer.writeByte(1);
    }
  }
}
