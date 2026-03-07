// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizerHiveModelAdapter extends TypeAdapter<OrganizerHiveModel> {
  @override
  final int typeId = 7;

  @override
  OrganizerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrganizerHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      organizationName: fields[2] as String,
      profilePicture: fields[3] as String?,
      bio: fields[4] as String?,
      contactPerson: fields[5] as String,
      phone: fields[6] as String,
      email: fields[7] as String,
      location: fields[8] as String,
      organizationType: fields[9] as String,
      eventTypes: (fields[10] as List).cast<String>(),
      verificationDocuments: (fields[11] as List).cast<String>(),
      website: fields[12] as String?,
      photos: (fields[13] as List).cast<String>(),
      videos: (fields[14] as List).cast<String>(),
      isVerified: fields[15] as bool,
      verificationRequested: fields[16] as bool,
      isActive: fields[17] as bool,
      createdAt: fields[18] as String,
      updatedAt: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrganizerHiveModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.organizationName)
      ..writeByte(3)
      ..write(obj.profilePicture)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.contactPerson)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.organizationType)
      ..writeByte(10)
      ..write(obj.eventTypes)
      ..writeByte(11)
      ..write(obj.verificationDocuments)
      ..writeByte(12)
      ..write(obj.website)
      ..writeByte(13)
      ..write(obj.photos)
      ..writeByte(14)
      ..write(obj.videos)
      ..writeByte(15)
      ..write(obj.isVerified)
      ..writeByte(16)
      ..write(obj.verificationRequested)
      ..writeByte(17)
      ..write(obj.isActive)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizerHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
