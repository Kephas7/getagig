import 'package:equatable/equatable.dart';
import '../../domain/entities/organizer_entity.dart';

enum OrganizerProfileStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class OrganizerProfileState extends Equatable {
  static const Object _unset = Object();

  final OrganizerProfileStatus status;
  final OrganizerEntity? profile;
  final String? errorMessage;

  const OrganizerProfileState({
    this.status = OrganizerProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  OrganizerProfileState copyWith({
    OrganizerProfileStatus? status,
    Object? profile = _unset,
    Object? errorMessage = _unset,
  }) {
    return OrganizerProfileState(
      status: status ?? this.status,
      profile: profile == _unset ? this.profile : profile as OrganizerEntity?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
