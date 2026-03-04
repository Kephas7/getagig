import 'package:equatable/equatable.dart';

class GigEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final List<String> genres;
  final List<String> instruments;
  final double payRate;
  final String eventType;
  final DateTime? deadline;
  final String status;
  final String organizerName;
  final String? organizerId;
  final DateTime? createdAt;

  const GigEntity({
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
    organizerName,
    organizerId,
    createdAt,
  ];
}
