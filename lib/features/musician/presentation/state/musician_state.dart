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
  static const Object _unset = Object();

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
    Object? profile = _unset,
    Object? errorMessage = _unset,
  }) {
    return MusicianProfileState(
      status: status ?? this.status,
      profile: profile == _unset ? this.profile : profile as MusicianEntity?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
