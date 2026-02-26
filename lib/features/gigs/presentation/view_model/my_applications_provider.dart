import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/data/models/application_model.dart';
import 'package:getagig/features/gigs/data/repositories/application_repository_impl.dart';

final myApplicationsProvider =
    AsyncNotifierProvider<MyApplicationsNotifier, List<ApplicationModel>>(() {
      return MyApplicationsNotifier();
    });

class MyApplicationsNotifier extends AsyncNotifier<List<ApplicationModel>> {
  @override
  Future<List<ApplicationModel>> build() async {
    return _fetchApplications();
  }

  Future<List<ApplicationModel>> _fetchApplications() async {
    final repo = ref.read(applicationRepositoryProvider);
    final result = await repo.getMyApplications();
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
    final repo = ref.read(applicationRepositoryProvider);
    final result = await repo.apply(gigId, coverLetter);
    
    result.fold(
      (failure) => throw failure.message,
      (application) {
        if (state.value != null) {
          state = AsyncValue.data([application, ...state.value!]);
        }
      },
    );
  }
}

