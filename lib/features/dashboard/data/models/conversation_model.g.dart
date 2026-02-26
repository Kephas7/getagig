// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationModelAdapter extends TypeAdapter<_$ConversationModelImpl> {
  @override
  final int typeId = 1;

  @override
  _$ConversationModelImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$ConversationModelImpl(
      id: fields[0] as String?,
      participants: (fields[1] as List).cast<AuthApiModel>(),
      lastMessage: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, _$ConversationModelImpl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(1)
      ..write(obj.participants);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationModelImpl _$$ConversationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ConversationModelImpl(
      id: _readId(json, '_id') as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => AuthApiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMessage: json['lastMessage'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConversationModelImplToJson(
        _$ConversationModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
