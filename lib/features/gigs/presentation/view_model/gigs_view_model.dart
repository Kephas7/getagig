import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/usecases/apply_to_gig_usecase.dart';
import '../state/gigs_state.dart';
import '../../domain/usecases/get_all_gigs_usecase.dart';

final gigsViewModelProvider = NotifierProvider<GigsViewModel, GigsState>(
  GigsViewModel.new,
);

class GigsViewModel extends Notifier<GigsState> {
  late final GetAllGigsUseCase _getAllGigsUseCase;
  late final ApplyToGigUseCase _applyToGigUseCase;

  @override
  GigsState build() {
    _getAllGigsUseCase = ref.read(getAllGigsUseCaseProvider);
    _applyToGigUseCase = ref.read(applyToGigUseCaseProvider);
    return const GigsState();
  }

  Future<void> getAllGigs() async {
    state = state.copyWith(status: GigsStatus.loading);
    final result = await _getAllGigsUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: GigsStatus.error,
        errorMessage: failure.message,
      ),
      (gigs) => state = state.copyWith(
        status: GigsStatus.loaded,
        gigs: gigs,
        errorMessage: null,
      ),
    );
  }

  Future<void> applyToGig(String gigId, String coverLetter) async {
    state = state.copyWith(status: GigsStatus.applying);
    final result = await _applyToGigUseCase(gigId, coverLetter);
    result.fold(
      (failure) => state = state.copyWith(
        status: GigsStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: GigsStatus.applied, errorMessage: null);
        // Refresh gigs list if necessary or just a success state
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
