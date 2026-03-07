import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:hive/hive.dart';

part 'gig_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.gigTypeId)
class GigHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final List<String> instruments;

  @HiveField(6)
  final double payRate;

  @HiveField(7)
  final String eventType;

  @HiveField(8)
  final DateTime? deadline;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final String organizerName;

  @HiveField(11)
  final String? organizerId;

  @HiveField(12)
  final DateTime? createdAt;

  GigHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.genres,
    required this.instruments,
    required this.payRate,
    required this.eventType,
    this.deadline,
    required this.status,
    required this.organizerName,
    this.organizerId,
    this.createdAt,
  });

  factory GigHiveModel.fromEntity(GigEntity entity) {
    return GigHiveModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      location: entity.location,
      genres: entity.genres,
      instruments: entity.instruments,
      payRate: entity.payRate,
      eventType: entity.eventType,
      deadline: entity.deadline,
      status: entity.status,
      organizerName: entity.organizerName,
      organizerId: entity.organizerId,
      createdAt: entity.createdAt,
    );
  }

  GigEntity toEntity() {
    return GigEntity(
      id: id,
      title: title,
      description: description,
      location: location,
      genres: genres,
      instruments: instruments,
      payRate: payRate,
      eventType: eventType,
      deadline: deadline,
      status: status,
      organizerName: organizerName,
      organizerId: organizerId,
      createdAt: createdAt,
    );
  }
}
