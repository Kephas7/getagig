import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/applications/data/repositories/application_repository.dart';
import 'package:getagig/features/applications/domain/usecases/apply_to_gig_usecase.dart';
import 'package:getagig/features/applications/domain/usecases/get_gig_applications_usecase.dart';
import 'package:getagig/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:getagig/features/applications/domain/usecases/update_application_status_usecase.dart';

final applyToGigUseCaseProvider = Provider<ApplyToGigUseCase>((ref) {
  return ApplyToGigUseCase(repository: ref.read(applicationRepositoryProvider));
});

final getMyApplicationsUseCaseProvider = Provider<GetMyApplicationsUseCase>((
  ref,
) {
  return GetMyApplicationsUseCase(
    repository: ref.read(applicationRepositoryProvider),
  );
});

final getGigApplicationsUseCaseProvider = Provider<GetGigApplicationsUseCase>((
  ref,
) {
  return GetGigApplicationsUseCase(
    repository: ref.read(applicationRepositoryProvider),
  );
});

final updateApplicationStatusUseCaseProvider =
    Provider<UpdateApplicationStatusUseCase>((ref) {
      return UpdateApplicationStatusUseCase(
        repository: ref.read(applicationRepositoryProvider),
      );
    });
