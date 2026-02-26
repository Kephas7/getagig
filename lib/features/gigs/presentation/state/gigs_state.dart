import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gig_entity.dart';

part 'gigs_state.freezed.dart';

enum GigsStatus { initial, loading, loaded, error, applying, applied }

@freezed
class GigsState with _$GigsState {
  const factory GigsState({
    @Default(GigsStatus.initial) GigsStatus status,
    @Default([]) List<GigEntity> gigs,
    String? errorMessage,
  }) = _GigsState;
}

