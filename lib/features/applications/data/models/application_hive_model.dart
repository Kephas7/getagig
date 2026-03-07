import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/applications/data/models/application_model.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:getagig/features/gigs/data/models/gig_model.dart';
import 'package:hive/hive.dart';

part 'application_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.applicationTypeId)
class ApplicationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? gigId;

  @HiveField(2)
  final String? musicianId;

  @HiveField(3)
  final String? musicianUserId;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String coverLetter;

  @HiveField(6)
  final DateTime? createdAt;

  @HiveField(7)
  final String? gigTitle;

  @HiveField(8)
  final String? gigDescription;

  @HiveField(9)
  final String? gigLocation;

  @HiveField(10)
  final double? gigPayRate;

  @HiveField(11)
  final String? gigEventType;

  @HiveField(12)
  final String? gigStatus;

  @HiveField(13)
  final String? gigOrganizerId;

  @HiveField(14)
  final String? gigOrganizerName;

  @HiveField(15)
  final List<String> gigGenres;

  @HiveField(16)
  final List<String> gigInstruments;

  @HiveField(17)
  final String? musicianName;

  @HiveField(18)
  final String? musicianEmail;

  @HiveField(19)
  final String? musicianRole;

  ApplicationHiveModel({
    required this.id,
    this.gigId,
    this.musicianId,
    this.musicianUserId,
    required this.status,
    required this.coverLetter,
    this.createdAt,
    this.gigTitle,
    this.gigDescription,
    this.gigLocation,
    this.gigPayRate,
    this.gigEventType,
    this.gigStatus,
    this.gigOrganizerId,
    this.gigOrganizerName,
    this.gigGenres = const [],
    this.gigInstruments = const [],
    this.musicianName,
    this.musicianEmail,
    this.musicianRole,
  });

  factory ApplicationHiveModel.fromModel(ApplicationModel model) {
    final generatedId =
        model.id ??
        '${model.gigId ?? 'gig'}-${model.musicianUserId ?? model.musicianId ?? DateTime.now().microsecondsSinceEpoch}';

    return ApplicationHiveModel(
      id: generatedId,
      gigId: model.gigId ?? model.gig?.id,
      musicianId: model.musicianId ?? model.musician?.id,
      musicianUserId: model.musicianUserId,
      status: model.status,
      coverLetter: model.coverLetter,
      createdAt: model.createdAt,
      gigTitle: model.gig?.title,
      gigDescription: model.gig?.description,
      gigLocation: model.gig?.location,
      gigPayRate: model.gig?.payRate,
      gigEventType: model.gig?.eventType,
      gigStatus: model.gig?.status,
      gigOrganizerId: model.gig?.organizer?.id,
      gigOrganizerName: model.gig?.organizer?.username,
      gigGenres: model.gig?.genres ?? const <String>[],
      gigInstruments: model.gig?.instruments ?? const <String>[],
      musicianName: model.musician?.username,
      musicianEmail: model.musician?.email,
      musicianRole: model.musician?.role,
    );
  }

  ApplicationModel toModel() {
    GigModel? gig;
    final title = gigTitle?.trim() ?? '';
    if (title.isNotEmpty) {
      AuthApiModel? organizer;
      final organizerName = gigOrganizerName?.trim() ?? '';
      final organizerId = gigOrganizerId?.trim() ?? '';
      if (organizerName.isNotEmpty || organizerId.isNotEmpty) {
        organizer = AuthApiModel(
          id: organizerId.isEmpty ? null : organizerId,
          username: organizerName.isEmpty ? 'Organizer' : organizerName,
          email: '',
          role: 'organizer',
        );
      }

      gig = GigModel(
        id: gigId,
        title: title,
        description: gigDescription ?? '',
        location: gigLocation ?? '',
        genres: gigGenres,
        instruments: gigInstruments,
        payRate: gigPayRate ?? 0,
        eventType: gigEventType ?? '',
        status: gigStatus ?? 'open',
        organizer: organizer,
      );
    }

    AuthApiModel? musician;
    final name = musicianName?.trim() ?? '';
    final email = musicianEmail?.trim() ?? '';
    final musicianIdValue = musicianId?.trim() ?? '';
    if (name.isNotEmpty || email.isNotEmpty || musicianIdValue.isNotEmpty) {
      musician = AuthApiModel(
        id: musicianIdValue.isEmpty ? null : musicianIdValue,
        username: name.isEmpty ? 'Musician' : name,
        email: email,
        role: (musicianRole?.trim().isNotEmpty ?? false)
            ? musicianRole!.trim()
            : 'musician',
      );
    }

    return ApplicationModel(
      id: id,
      gigId: gigId,
      musicianId: musicianId,
      musicianUserId: musicianUserId,
      gig: gig,
      musician: musician,
      status: status,
      coverLetter: coverLetter,
      createdAt: createdAt,
    );
  }

  ApplicationHiveModel copyWith({String? status}) {
    return ApplicationHiveModel(
      id: id,
      gigId: gigId,
      musicianId: musicianId,
      musicianUserId: musicianUserId,
      status: status ?? this.status,
      coverLetter: coverLetter,
      createdAt: createdAt,
      gigTitle: gigTitle,
      gigDescription: gigDescription,
      gigLocation: gigLocation,
      gigPayRate: gigPayRate,
      gigEventType: gigEventType,
      gigStatus: gigStatus,
      gigOrganizerId: gigOrganizerId,
      gigOrganizerName: gigOrganizerName,
      gigGenres: gigGenres,
      gigInstruments: gigInstruments,
      musicianName: musicianName,
      musicianEmail: musicianEmail,
      musicianRole: musicianRole,
    );
  }
}
