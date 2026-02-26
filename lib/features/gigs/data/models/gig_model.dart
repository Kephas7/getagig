import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_model.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import '../../domain/entities/gig_entity.dart';

part 'gig_model.freezed.dart';
part 'gig_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@freezed
class GigModel with _$GigModel {
  const factory GigModel({
    @JsonKey(name: '_id', readValue: _readId) String? id,
    required String title,
    @Default('') String description,
    @Default(LocationModel()) LocationModel location,
    @Default([]) List<String> genres,
    @Default([]) List<String> instruments,
    @Default(0.0) double payRate,
    @Default('') String eventType,
    DateTime? deadline,
    @Default('open') String status,
    AuthApiModel? organizer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GigModel;

  factory GigModel.fromJson(Map<String, dynamic> json) =>
      _$GigModelFromJson(json);

  const GigModel._();

  GigEntity toEntity() {
    return GigEntity(
      id: id ?? '',
      title: title,
      description: description,
      city: location.city,
      state: location.state,
      country: location.country,
      genres: genres,
      instruments: instruments,
      payRate: payRate,
      eventType: eventType,
      deadline: deadline,
      status: status,
      organizerName: organizer?.username ?? '',
      organizerId: organizer?.id,
      createdAt: createdAt,
    );
  }
}

