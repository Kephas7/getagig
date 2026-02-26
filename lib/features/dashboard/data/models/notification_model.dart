import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@freezed
class NotificationModel with _$NotificationModel {
  @HiveType(typeId: HiveTableConstant.notificationTypeId, adapterName: 'NotificationModelAdapter')
  const factory NotificationModel({
    @HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
    @HiveField(1) String? userId,
    @HiveField(2) required String type,
    @HiveField(3) required String title,
    @HiveField(4) required String content,
    @HiveField(5) String? relatedId,
    @HiveField(6) @Default(false) bool isRead,
    @HiveField(7) DateTime? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
