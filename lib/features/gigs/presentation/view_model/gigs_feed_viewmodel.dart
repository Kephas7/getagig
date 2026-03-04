import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/usecases/get_all_gigs_usecase.dart';

final gigsFeedProvider = AsyncNotifierProvider<GigsFeedNotifier, List<GigEntity>>(() {
  return GigsFeedNotifier();
});

class GigsFeedNotifier extends AsyncNotifier<List<GigEntity>> {
  late final GetAllGigsUseCase _getAllGigsUseCase;

  @override
  Future<List<GigEntity>> build() async {
    _getAllGigsUseCase = ref.read(getAllGigsUseCaseProvider);
    return _fetchGigs();
  }

  Future<List<GigEntity>> _fetchGigs() async {
    final result = await _getAllGigsUseCase();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (gigs) => gigs,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGigs());
  }
}

