import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/applications/data/datasources/applications_datasource.dart';
import 'package:getagig/features/applications/data/models/application_hive_model.dart';

final applicationsLocalDataSourceProvider =
    Provider<IApplicationsLocalDataSource>((ref) {
      return ApplicationsLocalDataSource(ref.read(hiveServiceProvider));
    });

class ApplicationsLocalDataSource implements IApplicationsLocalDataSource {
  final HiveService _hiveService;

  ApplicationsLocalDataSource(this._hiveService);

  @override
  Future<void> cacheMyApplications(
    String userId,
    List<ApplicationHiveModel> applications,
  ) {
    return _hiveService.saveMyApplications(userId, applications);
  }

  @override
  Future<void> cacheGigApplications(
    String gigId,
    List<ApplicationHiveModel> applications,
  ) {
    return _hiveService.saveGigApplications(gigId, applications);
  }

  @override
  Future<List<ApplicationHiveModel>> getMyApplications(String userId) async {
    return _hiveService.getMyApplications(userId);
  }

  @override
  Future<List<ApplicationHiveModel>> getGigApplications(String gigId) async {
    return _hiveService.getGigApplications(gigId);
  }

  @override
  Future<void> upsertApplication(ApplicationHiveModel application) {
    return _hiveService.upsertApplication(application);
  }

  @override
  Future<void> updateStatus(String applicationId, String status) {
    return _hiveService.updateApplicationStatus(applicationId, status);
  }
}
