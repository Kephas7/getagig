import 'package:equatable/equatable.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/gigs/data/models/gig_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_model.g.dart';

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json['_id'] ?? json['id'];
}

Object? _readMusicianUserId(Map<dynamic, dynamic> json, String key) {
  final musician = json['musician'];
  if (musician is! Map) return null;

  final rawUserId = musician['userId'];
  if (rawUserId is Map) {
    return rawUserId['_id'] ?? rawUserId['id'];
  }

  return rawUserId;
}

@JsonSerializable()
class ApplicationModel extends Equatable {
  static const Object _unset = Object();

  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  final String? gigId;
  final String? musicianId;

  @JsonKey(readValue: _readMusicianUserId)
  final String? musicianUserId;

  final GigModel? gig;
  final AuthApiModel? musician;
  final String status;
  final String coverLetter;
  final DateTime? createdAt;

  const ApplicationModel({
    this.id,
    this.gigId,
    this.musicianId,
    this.musicianUserId,
    this.gig,
    this.musician,
    this.status = 'pending',
    this.coverLetter = '',
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$ApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationModelToJson(this);

  ApplicationModel copyWith({
    Object? id = _unset,
    Object? gigId = _unset,
    Object? musicianId = _unset,
    Object? musicianUserId = _unset,
    Object? gig = _unset,
    Object? musician = _unset,
    String? status,
    String? coverLetter,
    Object? createdAt = _unset,
  }) {
    return ApplicationModel(
      id: id == _unset ? this.id : id as String?,
      gigId: gigId == _unset ? this.gigId : gigId as String?,
      musicianId: musicianId == _unset
          ? this.musicianId
          : musicianId as String?,
      musicianUserId: musicianUserId == _unset
          ? this.musicianUserId
          : musicianUserId as String?,
      gig: gig == _unset ? this.gig : gig as GigModel?,
      musician: musician == _unset ? this.musician : musician as AuthApiModel?,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      createdAt: createdAt == _unset ? this.createdAt : createdAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    gigId,
    musicianId,
    musicianUserId,
    gig,
    musician,
    status,
    coverLetter,
    createdAt,
  ];

  ApplicationEntity toEntity() {
    return ApplicationEntity(
      id: id,
      gigId: gigId,
      musicianId: musicianId,
      musicianUserId: musicianUserId,
      gig: gig?.toEntity(),
      musician: musician == null
          ? null
          : ApplicationApplicantEntity(
              id: musician!.id,
              userId: musicianUserId,
              username: musician!.username,
              email: musician!.email,
              role: musician!.role,
            ),
      status: status,
      coverLetter: coverLetter,
      createdAt: createdAt,
    );
  }
}
