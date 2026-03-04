import 'package:equatable/equatable.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@HiveType(
  typeId: HiveTableConstant.messageTypeId,
  adapterName: 'MessageModelAdapter',
)
@JsonSerializable()
class MessageModel extends Equatable {
  static const Object _unset = Object();

  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;

  @HiveField(1)
  final String? conversationId;

  @HiveField(2)
  final String? senderId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final DateTime? createdAt;

  const MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    required this.content,
    this.isRead = false,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    Object? id = _unset,
    Object? conversationId = _unset,
    Object? senderId = _unset,
    String? content,
    bool? isRead,
    Object? createdAt = _unset,
  }) {
    return MessageModel(
      id: id == _unset ? this.id : id as String?,
      conversationId: conversationId == _unset
          ? this.conversationId
          : conversationId as String?,
      senderId: senderId == _unset ? this.senderId : senderId as String?,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    content,
    isRead,
    createdAt,
  ];
}
