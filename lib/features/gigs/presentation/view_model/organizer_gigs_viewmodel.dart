import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/usecases/create_gig_usecase.dart';
import 'package:getagig/features/gigs/domain/usecases/delete_gig_usecase.dart';
import 'package:getagig/features/gigs/domain/usecases/update_gig_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_usecase.dart';
import 'package:getagig/features/gigs/domain/usecases/get_all_gigs_usecase.dart';

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
    final getAllGigs = ref.read(getAllGigsUseCaseProvider);

    final organizerProfileResult = await getOrganizerProfile();
    final organizerProfile = organizerProfileResult.fold(
      (failure) => throw failure,
      (profile) => profile,
    );

    final gigsResult = await getAllGigs(organizerId: organizerProfile.id);
    return gigsResult.fold((failure) => throw failure, (gigs) => gigs);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGigs());
  }

  Future<void> createGig(Map<String, dynamic> data) async {
    final useCase = ref.read(createGigUseCaseProvider);
    final result = await useCase(data);
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
    final useCase = ref.read(updateGigUseCaseProvider);
    final result = await useCase(id, updates);
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
    final useCase = ref.read(deleteGigUseCaseProvider);
    final result = await useCase(id);
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
