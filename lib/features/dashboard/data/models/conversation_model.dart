import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:hive/hive.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@freezed
class ConversationModel with _$ConversationModel {
  @HiveType(typeId: HiveTableConstant.conversationTypeId, adapterName: 'ConversationModelAdapter')
  const factory ConversationModel({
    @HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
    @HiveField(1) @Default([]) List<AuthApiModel> participants,
    @HiveField(2) String? lastMessage,
    @HiveField(3) DateTime? createdAt,
    @HiveField(4) DateTime? updatedAt,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);
}

extension ConversationModelX on ConversationModel {
  /// Returns a best-effort participant name (first participant besides current user)
  String get participantName {
    if (participants.isEmpty) return '';
    final first = participants.first;
    return first.username ?? first.email ?? '';
  }

  /// Safe non-null id
  String get safeId => id ?? '';
}
