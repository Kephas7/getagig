import 'package:equatable/equatable.dart';
import '../../domain/entities/gig_entity.dart';

enum GigsStatus { initial, loading, loaded, error, applying, applied }

class GigsState extends Equatable {
  static const Object _unset = Object();

  final GigsStatus status;
  final List<GigEntity> gigs;
  final String? errorMessage;

  const GigsState({
    this.status = GigsStatus.initial,
    this.gigs = const [],
    this.errorMessage,
  });

  GigsState copyWith({
    GigsStatus? status,
    List<GigEntity>? gigs,
    Object? errorMessage = _unset,
  }) {
    return GigsState(
      status: status ?? this.status,
      gigs: gigs ?? this.gigs,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, gigs, errorMessage];
}
