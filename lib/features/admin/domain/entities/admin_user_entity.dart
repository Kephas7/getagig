import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
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

  const AdminUserEntity({
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

  AdminUserEntity copyWith({
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
    return AdminUserEntity(
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
