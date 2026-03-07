import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';

final gigApplicationsProvider =
    FutureProvider.family<List<ApplicationEntity>, String>((ref, gigId) async {
      final useCase = ref.read(getGigApplicationsUseCaseProvider);
      final result = await useCase(gigId);
      return result.fold((failure) => throw failure.message, (apps) => apps);
    });
