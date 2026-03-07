import 'package:getagig/features/applications/data/models/application_hive_model.dart';
import 'package:getagig/features/applications/data/models/application_model.dart';

abstract interface class IApplicationsRemoteDataSource {
  Future<List<ApplicationModel>> getMyApplications();
  Future<List<ApplicationModel>> getGigApplications(String gigId);
  Future<ApplicationModel> apply(String gigId, String coverLetter);
  Future<void> updateStatus(String applicationId, String status);
}

abstract interface class IApplicationsLocalDataSource {
  Future<void> cacheMyApplications(
    String userId,
    List<ApplicationHiveModel> applications,
  );
  Future<void> cacheGigApplications(
    String gigId,
    List<ApplicationHiveModel> applications,
  );
  Future<List<ApplicationHiveModel>> getMyApplications(String userId);
  Future<List<ApplicationHiveModel>> getGigApplications(String gigId);
  Future<void> upsertApplication(ApplicationHiveModel application);
  Future<void> updateStatus(String applicationId, String status);
}
