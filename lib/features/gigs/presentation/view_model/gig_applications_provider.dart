import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/data/models/application_model.dart';
import 'package:getagig/features/gigs/data/repositories/application_repository_impl.dart';

final gigApplicationsProvider =
    FutureProvider.family<List<ApplicationModel>, String>((ref, gigId) async {
  final repo = ref.read(applicationRepositoryProvider);
  final result = await repo.getGigApplications(gigId);
  return result.fold(
    (failure) => throw failure.message,
    (apps) => apps,
  );
});

