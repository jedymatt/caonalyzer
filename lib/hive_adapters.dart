import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:hive_flutter/adapters.dart';

class PreferredModeAdapter extends TypeAdapter<PreferredMode> {
  @override
  PreferredMode read(BinaryReader reader) {
    final mode = reader.readInt();
    return PreferredMode.values[mode];
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, PreferredMode obj) {
    writer.writeInt(obj.index);
  }
}
