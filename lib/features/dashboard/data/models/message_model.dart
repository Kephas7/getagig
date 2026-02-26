import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@freezed
class MessageModel with _$MessageModel {
  @HiveType(typeId: HiveTableConstant.messageTypeId, adapterName: 'MessageModelAdapter')
  const factory MessageModel({
    @HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
    @HiveField(1) String? conversationId,
    @HiveField(2) String? senderId,
    @HiveField(3) required String content,
    @HiveField(4) @Default(false) bool isRead,
    @HiveField(5) DateTime? createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
