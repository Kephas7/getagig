// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplicationHiveModelAdapter extends TypeAdapter<ApplicationHiveModel> {
  @override
  final int typeId = 8;

  @override
  ApplicationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationHiveModel(
      id: fields[0] as String,
      gigId: fields[1] as String?,
      musicianId: fields[2] as String?,
      musicianUserId: fields[3] as String?,
      status: fields[4] as String,
      coverLetter: fields[5] as String,
      createdAt: fields[6] as DateTime?,
      gigTitle: fields[7] as String?,
      gigDescription: fields[8] as String?,
      gigLocation: fields[9] as String?,
      gigPayRate: fields[10] as double?,
      gigEventType: fields[11] as String?,
      gigStatus: fields[12] as String?,
      gigOrganizerId: fields[13] as String?,
      gigOrganizerName: fields[14] as String?,
      gigGenres: (fields[15] as List).cast<String>(),
      gigInstruments: (fields[16] as List).cast<String>(),
      musicianName: fields[17] as String?,
      musicianEmail: fields[18] as String?,
      musicianRole: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationHiveModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gigId)
      ..writeByte(2)
      ..write(obj.musicianId)
      ..writeByte(3)
      ..write(obj.musicianUserId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.coverLetter)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.gigTitle)
      ..writeByte(8)
      ..write(obj.gigDescription)
      ..writeByte(9)
      ..write(obj.gigLocation)
      ..writeByte(10)
      ..write(obj.gigPayRate)
      ..writeByte(11)
      ..write(obj.gigEventType)
      ..writeByte(12)
      ..write(obj.gigStatus)
      ..writeByte(13)
      ..write(obj.gigOrganizerId)
      ..writeByte(14)
      ..write(obj.gigOrganizerName)
      ..writeByte(15)
      ..write(obj.gigGenres)
      ..writeByte(16)
      ..write(obj.gigInstruments)
      ..writeByte(17)
      ..write(obj.musicianName)
      ..writeByte(18)
      ..write(obj.musicianEmail)
      ..writeByte(19)
      ..write(obj.musicianRole);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
