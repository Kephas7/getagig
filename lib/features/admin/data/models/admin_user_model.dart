import 'package:equatable/equatable.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';

class AdminUserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String role;
  final bool isVerified;
  final bool verificationRequested;
  final String? profileId;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.verificationRequested,
    this.profileId,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });

  bool get isVerifiableRole {
    final normalizedRole = role.toLowerCase();
    return normalizedRole == 'musician' || normalizedRole == 'organizer';
  }

  AdminUserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    bool? isVerified,
    bool? verificationRequested,
    String? profileId,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      verificationRequested:
          verificationRequested ?? this.verificationRequested,
      profileId: profileId ?? this.profileId,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      isVerified: _parseBool(json['isVerified']),
      verificationRequested: _parseBool(json['verificationRequested']),
      profileId: json['profileId']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
    );
  }

  factory AdminUserModel.fromEntity(AdminUserEntity entity) {
    return AdminUserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      role: entity.role,
      isVerified: entity.isVerified,
      verificationRequested: entity.verificationRequested,
      profileId: entity.profileId,
      profilePicture: entity.profilePicture,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AdminUserEntity toEntity() {
    return AdminUserEntity(
      id: id,
      username: username,
      email: email,
      role: role,
      isVerified: isVerified,
      verificationRequested: verificationRequested,
      profileId: profileId,
      profilePicture: profilePicture,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    role,
    isVerified,
    verificationRequested,
    profileId,
    profilePicture,
    createdAt,
    updatedAt,
  ];
}
