import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/admin/data/repositories/admin_repository.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/usecases/create_admin_user_usecase.dart';
import 'package:getagig/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:getagig/features/admin/domain/usecases/get_admin_users_usecase.dart';
import 'package:getagig/features/admin/domain/usecases/update_admin_user_usecase.dart';
import 'package:getagig/features/admin/domain/usecases/update_admin_user_verification_usecase.dart';

final createAdminUserUseCaseProvider = Provider<CreateAdminUserUseCase>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return CreateAdminUserUseCase(repository: repository);
});

final getAdminUsersUseCaseProvider = Provider<GetAdminUsersUseCase>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return GetAdminUsersUseCase(repository: repository);
});

final updateAdminUserVerificationUseCaseProvider =
    Provider<UpdateAdminUserVerificationUseCase>((ref) {
      final repository = ref.read(adminRepositoryProvider);
      return UpdateAdminUserVerificationUseCase(repository: repository);
    });

final deleteAdminUserUseCaseProvider = Provider<DeleteAdminUserUseCase>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return DeleteAdminUserUseCase(repository: repository);
});

final updateAdminUserUseCaseProvider = Provider<UpdateAdminUserUseCase>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return UpdateAdminUserUseCase(repository: repository);
});

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserEntity>>(() {
      return AdminUsersNotifier();
    });

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserEntity>> {
  @override
  Future<List<AdminUserEntity>> build() async {
    return _fetchUsers();
  }

  Future<List<AdminUserEntity>> _fetchUsers() async {
    final useCase = ref.read(getAdminUsersUseCaseProvider);
    final result = await useCase(const GetAdminUsersParams());

    return result.fold((failure) => throw failure.message, (users) => users);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<String?> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final useCase = ref.read(createAdminUserUseCaseProvider);
    final result = await useCase(
      CreateAdminUserParams(
        username: username,
        email: email,
        password: password,
        role: role,
      ),
    );

    return result.fold((failure) => failure.message, (createdUser) {
      final currentUsers = state.value ?? const <AdminUserEntity>[];
      final nextUsers = [
        createdUser,
        ...currentUsers.where((item) => item.id != createdUser.id),
      ];
      state = AsyncValue.data(nextUsers);
      return null;
    });
  }

  Future<String?> setVerificationStatus({
    required AdminUserEntity user,
    required bool isVerified,
    String? rejectionReason,
  }) async {
    final useCase = ref.read(updateAdminUserVerificationUseCaseProvider);
    final result = await useCase(
      UpdateAdminUserVerificationParams(
        user: user,
        isVerified: isVerified,
        rejectionReason: rejectionReason,
      ),
    );

    return result.fold((failure) => failure.message, (_) {
      final currentUsers = state.value ?? const <AdminUserEntity>[];
      state = AsyncValue.data(
        currentUsers
            .map(
              (item) => item.id == user.id
                  ? item.copyWith(
                      isVerified: isVerified,
                      verificationRequested: false,
                    )
                  : item,
            )
            .toList(),
      );
      return null;
    });
  }

  Future<String?> deleteUser(String userId) async {
    final useCase = ref.read(deleteAdminUserUseCaseProvider);
    final result = await useCase(DeleteAdminUserParams(userId: userId));

    return result.fold((failure) => failure.message, (_) {
      final currentUsers = state.value ?? const <AdminUserEntity>[];
      state = AsyncValue.data(
        currentUsers.where((item) => item.id != userId).toList(),
      );
      return null;
    });
  }

  Future<String?> updateUser({
    required String userId,
    required String username,
    required String email,
    required String role,
    String? password,
  }) async {
    final useCase = ref.read(updateAdminUserUseCaseProvider);
    final result = await useCase(
      UpdateAdminUserParams(
        userId: userId,
        username: username,
        email: email,
        role: role,
        password: password,
      ),
    );

    return result.fold((failure) => failure.message, (updatedUser) {
      final currentUsers = state.value ?? const <AdminUserEntity>[];
      state = AsyncValue.data(
        currentUsers
            .map((item) => item.id == updatedUser.id ? updatedUser : item)
            .toList(),
      );
      return null;
    });
  }
}
