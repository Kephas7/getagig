import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/organizer_entity.dart';

part 'organizer_state.freezed.dart';

enum OrganizerProfileStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

@freezed
class OrganizerProfileState with _$OrganizerProfileState {
  const factory OrganizerProfileState({
    @Default(OrganizerProfileStatus.initial) OrganizerProfileStatus status,
    OrganizerEntity? profile,
    String? errorMessage,
  }) = _OrganizerProfileState;
}

