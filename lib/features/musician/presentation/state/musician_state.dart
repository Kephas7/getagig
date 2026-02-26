import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/musician_entity.dart';

part 'musician_state.freezed.dart';

enum MusicianProfileStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

@freezed
class MusicianProfileState with _$MusicianProfileState {
  const factory MusicianProfileState({
    @Default(MusicianProfileStatus.initial) MusicianProfileStatus status,
    MusicianEntity? profile,
    String? errorMessage,
  }) = _MusicianProfileState;
}

