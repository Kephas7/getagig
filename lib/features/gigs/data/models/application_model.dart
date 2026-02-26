import 'package:freezed_annotation/freezed_annotation.dart';
import 'gig_model.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';

part 'application_model.freezed.dart';
part 'application_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@freezed
class ApplicationModel with _$ApplicationModel {
  const factory ApplicationModel({
    @JsonKey(name: '_id', readValue: _readId) String? id,
    String? gigId,
    String? musicianId,
    GigModel? gig,
    AuthApiModel? musician,
    @Default('pending') String status,
    @Default('') String coverLetter,
    DateTime? createdAt,
  }) = _ApplicationModel;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$ApplicationModelFromJson(json);
}

