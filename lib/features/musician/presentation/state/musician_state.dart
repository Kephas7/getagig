import 'package:equatable/equatable.dart';
import '../../domain/entities/musician_entity.dart';

enum MusicianProfileStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class MusicianProfileState extends Equatable {
  final MusicianProfileStatus status;
  final MusicianEntity? profile;
  final String? errorMessage;

  const MusicianProfileState({
    this.status = MusicianProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  MusicianProfileState copyWith({
    MusicianProfileStatus? status,
    MusicianEntity? profile,
    bool resetProfile = false,
    String? errorMessage,
    bool resetErrorMessage = false,
  }) {
    return MusicianProfileState(
      status: status ?? this.status,
      profile: resetProfile ? null : (profile ?? this.profile),
      errorMessage: resetErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
