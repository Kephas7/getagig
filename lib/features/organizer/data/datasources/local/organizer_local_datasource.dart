import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/organizer/data/datasources/organizer_datasource.dart';
import 'package:getagig/features/organizer/data/models/organizer_hive_model.dart';

final organizerLocalDataSourceProvider = Provider<IOrganizerLocalDataSource>((
  ref,
) {
  return OrganizerLocalDataSource(ref.read(hiveServiceProvider));
});

class OrganizerLocalDataSource implements IOrganizerLocalDataSource {
  final HiveService _hiveService;

  OrganizerLocalDataSource(this._hiveService);

  @override
  Future<void> cacheProfile(OrganizerHiveModel profile) {
    return _hiveService.saveOrganizerProfile(profile);
  }

  @override
  Future<OrganizerHiveModel?> getCachedProfileById(String id) async {
    return _hiveService.getOrganizerProfileById(id);
  }

  @override
  Future<OrganizerHiveModel?> getCachedProfileByUserId(String userId) async {
    return _hiveService.getOrganizerProfileByUserId(userId);
  }

  @override
  Future<void> deleteCachedProfileById(String id) {
    return _hiveService.deleteOrganizerProfileById(id);
  }

  @override
  Future<void> deleteCachedProfileByUserId(String userId) {
    return _hiveService.deleteOrganizerProfileByUserId(userId);
  }
}
