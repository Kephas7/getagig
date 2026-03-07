import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/admin/data/repositories/admin_repository.dart';
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
