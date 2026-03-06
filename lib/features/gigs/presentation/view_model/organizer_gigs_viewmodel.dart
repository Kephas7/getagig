import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_usecase.dart';

final organizerGigsProvider =
    AsyncNotifierProvider<OrganizerGigsNotifier, List<GigEntity>>(() {
      return OrganizerGigsNotifier();
    });

class OrganizerGigsNotifier extends AsyncNotifier<List<GigEntity>> {
  @override
  Future<List<GigEntity>> build() async {
    return _fetchGigs();
  }

  Future<List<GigEntity>> _fetchGigs() async {
    final getOrganizerProfile = ref.read(getOrganizerProfileUseCaseProvider);
    final repo = ref.read(gigRepositoryProvider);

    final organizerProfileResult = await getOrganizerProfile();
    final organizerProfile = organizerProfileResult.fold(
      (failure) => throw failure,
      (profile) => profile,
    );

    final gigsResult = await repo.getAllGigs(organizerId: organizerProfile.id);
    return gigsResult.fold((failure) => throw failure, (gigs) => gigs);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGigs());
  }

  Future<void> createGig(Map<String, dynamic> data) async {
    final repo = ref.read(gigRepositoryProvider);
    final result = await repo.createGig(data);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdGig) {
        if (state.value != null) {
          state = AsyncValue.data([createdGig, ...state.value!]);
        }
      },
    );
  }

  Future<void> updateGig(String id, Map<String, dynamic> updates) async {
    final repo = ref.read(gigRepositoryProvider);
    final result = await repo.updateGig(id, updates);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (updatedGig) {
        if (state.value != null) {
          state = AsyncValue.data(
            state.value!.map((g) => g.id == id ? updatedGig : g).toList(),
          );
        }
      },
    );
  }

  Future<void> deleteGig(String id) async {
    final repo = ref.read(gigRepositoryProvider);
    final result = await repo.deleteGig(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        if (state.value != null) {
          state = AsyncValue.data(
            state.value!.where((g) => g.id != id).toList(),
          );
        }
      },
    );
  }
}
