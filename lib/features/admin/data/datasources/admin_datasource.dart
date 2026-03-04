import 'package:getagig/features/admin/data/models/admin_user_model.dart';

abstract interface class IAdminRemoteDataSource {
  Future<AdminUserModel> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<List<AdminUserModel>> getUsers({int page, int limit});

  Future<void> setVerificationStatus({
    required String userId,
    required String role,
    required bool isVerified,
    String? rejectionReason,
  });

  Future<void> deleteUser(String userId);

  Future<AdminUserModel> updateUser({
    required String userId,
    required String username,
    required String email,
    required String role,
    String? password,
  });
}
