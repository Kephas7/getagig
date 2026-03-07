import 'package:equatable/equatable.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

Object? _readLastMessage(Map<dynamic, dynamic> json, String key) {
  final raw = json['lastMessage'];
  if (raw == null) return null;

  if (raw is String) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final content = map['content'] ?? map['message'] ?? map['text'];
    if (content is String) {
      final trimmed = content.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
  }

  final fallback = raw.toString().trim();
  return fallback.isEmpty ? null : fallback;
}

@HiveType(
  typeId: HiveTableConstant.conversationTypeId,
  adapterName: 'ConversationModelAdapter',
)
@JsonSerializable()
class ConversationModel extends Equatable {
  static const Object _unset = Object();

  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;

  @HiveField(1)
  final List<AuthApiModel> participants;

  @HiveField(2)
  @JsonKey(readValue: _readLastMessage)
  final String? lastMessage;

  @HiveField(3)
  final DateTime? createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  const ConversationModel({
    this.id,
    this.participants = const [],
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  ConversationModel copyWith({
    Object? id = _unset,
    List<AuthApiModel>? participants,
    Object? lastMessage = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return ConversationModel(
      id: id == _unset ? this.id : id as String?,
      participants: participants ?? this.participants,
      lastMessage: lastMessage == _unset
          ? this.lastMessage
          : lastMessage as String?,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
      updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participants,
    lastMessage,
    createdAt,
    updatedAt,
  ];
}

extension ConversationModelX on ConversationModel {
  /// Returns a best-effort participant name (first participant besides current user)
  String get participantName {
    if (participants.isEmpty) return '';
    final first = participants.first;
    return first.username.trim().isNotEmpty ? first.username : first.email;
  }

  /// Safe non-null id
  String get safeId => id ?? '';
}
