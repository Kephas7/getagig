import 'package:equatable/equatable.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';

class ApplicationApplicantEntity extends Equatable {
  final String? id;
  final String? userId;
  final String username;
  final String email;
  final String role;

  const ApplicationApplicantEntity({
    this.id,
    this.userId,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, userId, username, email, role];
}

class ApplicationEntity extends Equatable {
  final String? id;
  final String? gigId;
  final String? musicianId;
  final String? musicianUserId;
  final GigEntity? gig;
  final ApplicationApplicantEntity? musician;
  final String status;
  final String coverLetter;
  final DateTime? createdAt;

  const ApplicationEntity({
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
}
