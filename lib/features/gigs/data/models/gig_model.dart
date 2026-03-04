import 'package:equatable/equatable.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import '../../domain/entities/gig_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gig_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

@JsonSerializable()
class GigModel extends Equatable {
  static const Object _unset = Object();

  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  final String title;
  final String description;
  final String location;
  final List<String> genres;
  final List<String> instruments;
  final double payRate;
  final String eventType;
  final DateTime? deadline;
  final String status;
  final AuthApiModel? organizer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GigModel({
    this.id,
    required this.title,
    this.description = '',
    this.location = '',
    this.genres = const [],
    this.instruments = const [],
    this.payRate = 0.0,
    this.eventType = '',
    this.deadline,
    this.status = 'open',
    this.organizer,
    this.createdAt,
    this.updatedAt,
  });

  factory GigModel.fromJson(Map<String, dynamic> json) =>
      _$GigModelFromJson(json);

  Map<String, dynamic> toJson() => _$GigModelToJson(this);

  GigModel copyWith({
    Object? id = _unset,
    String? title,
    String? description,
    String? location,
    List<String>? genres,
    List<String>? instruments,
    double? payRate,
    String? eventType,
    Object? deadline = _unset,
    String? status,
    Object? organizer = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return GigModel(
      id: id == _unset ? this.id : id as String?,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      genres: genres ?? this.genres,
      instruments: instruments ?? this.instruments,
      payRate: payRate ?? this.payRate,
      eventType: eventType ?? this.eventType,
      deadline: deadline == _unset ? this.deadline : deadline as DateTime?,
      status: status ?? this.status,
      organizer: organizer == _unset
          ? this.organizer
          : organizer as AuthApiModel?,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
      updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
    );
  }

  GigEntity toEntity() {
    return GigEntity(
      id: id ?? '',
      title: title,
      description: description,
      location: location,
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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    location,
    genres,
    instruments,
    payRate,
    eventType,
    deadline,
    status,
    organizer,
    createdAt,
    updatedAt,
  ];
}
