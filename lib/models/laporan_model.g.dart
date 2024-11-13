// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LaporanHiveModelAdapter extends TypeAdapter<LaporanHiveModel> {
  @override
  final int typeId = 0;

  @override
  LaporanHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LaporanHiveModel(
      id: fields[0] as String,
      laporan_type: fields[1] as String,
      category: fields[2] as String,
      date: fields[3] as DateTime,
      amount: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LaporanHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.laporan_type)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaporanHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
