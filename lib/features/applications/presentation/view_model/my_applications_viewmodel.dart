import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';

final myApplicationsProvider =
    AsyncNotifierProvider<MyApplicationsNotifier, List<ApplicationEntity>>(() {
      return MyApplicationsNotifier();
    });

class MyApplicationsNotifier extends AsyncNotifier<List<ApplicationEntity>> {
  @override
  Future<List<ApplicationEntity>> build() async {
    return _fetchApplications();
  }

  Future<List<ApplicationEntity>> _fetchApplications() async {
    final useCase = ref.read(getMyApplicationsUseCaseProvider);
    final result = await useCase();
    return result.fold(
      (failure) => throw failure.message,
      (applications) => applications,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchApplications());
  }

  Future<void> apply(String gigId, String coverLetter) async {
    final useCase = ref.read(applyToGigUseCaseProvider);
    final result = await useCase(gigId, coverLetter);

    await result.fold((failure) => throw failure.message, (_) async {
      await refresh();
    });
  }
}
