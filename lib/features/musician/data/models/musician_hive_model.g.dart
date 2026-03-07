// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musician_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicianHiveModelAdapter extends TypeAdapter<MusicianHiveModel> {
  @override
  final int typeId = 6;

  @override
  MusicianHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MusicianHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      stageName: fields[2] as String,
      profilePicture: fields[3] as String?,
      bio: fields[4] as String?,
      phone: fields[5] as String,
      location: fields[6] as String,
      genres: (fields[7] as List).cast<String>(),
      instruments: (fields[8] as List).cast<String>(),
      experienceYears: fields[9] as int,
      hourlyRate: fields[10] as double?,
      photos: (fields[11] as List).cast<String>(),
      videos: (fields[12] as List).cast<String>(),
      audioSamples: (fields[13] as List).cast<String>(),
      isVerified: fields[14] as bool,
      verificationRequested: fields[15] as bool,
      isAvailable: fields[16] as bool,
      createdAt: fields[17] as String,
      updatedAt: fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MusicianHiveModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.stageName)
      ..writeByte(3)
      ..write(obj.profilePicture)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.instruments)
      ..writeByte(9)
      ..write(obj.experienceYears)
      ..writeByte(10)
      ..write(obj.hourlyRate)
      ..writeByte(11)
      ..write(obj.photos)
      ..writeByte(12)
      ..write(obj.videos)
      ..writeByte(13)
      ..write(obj.audioSamples)
      ..writeByte(14)
      ..write(obj.isVerified)
      ..writeByte(15)
      ..write(obj.verificationRequested)
      ..writeByte(16)
      ..write(obj.isAvailable)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicianHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
