import 'package:equatable/equatable.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@HiveType(
  typeId: HiveTableConstant.notificationTypeId,
  adapterName: 'NotificationModelAdapter',
)
@JsonSerializable()
class NotificationModel extends Equatable {
  static const Object _unset = Object();

  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final String? relatedId;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.relatedId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    Object? id = _unset,
    Object? userId = _unset,
    String? type,
    String? title,
    String? content,
    Object? relatedId = _unset,
    bool? isRead,
    Object? createdAt = _unset,
  }) {
    return NotificationModel(
      id: id == _unset ? this.id : id as String?,
      userId: userId == _unset ? this.userId : userId as String?,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      relatedId: relatedId == _unset ? this.relatedId : relatedId as String?,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    content,
    relatedId,
    isRead,
    createdAt,
  ];
}
