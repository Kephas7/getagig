// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GigHiveModelAdapter extends TypeAdapter<GigHiveModel> {
  @override
  final int typeId = 5;

  @override
  GigHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GigHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      location: fields[3] as String,
      genres: (fields[4] as List).cast<String>(),
      instruments: (fields[5] as List).cast<String>(),
      payRate: fields[6] as double,
      eventType: fields[7] as String,
      deadline: fields[8] as DateTime?,
      status: fields[9] as String,
      organizerName: fields[10] as String,
      organizerId: fields[11] as String?,
      createdAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GigHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.instruments)
      ..writeByte(6)
      ..write(obj.payRate)
      ..writeByte(7)
      ..write(obj.eventType)
      ..writeByte(8)
      ..write(obj.deadline)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.organizerName)
      ..writeByte(11)
      ..write(obj.organizerId)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GigHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
