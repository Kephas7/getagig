import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/models/musician_hive_model.dart';

final musicianLocalDataSourceProvider = Provider<IMusicianLocalDataSource>((
  ref,
) {
  return MusicianLocalDataSource(ref.read(hiveServiceProvider));
});

class MusicianLocalDataSource implements IMusicianLocalDataSource {
  final HiveService _hiveService;

  MusicianLocalDataSource(this._hiveService);

  @override
  Future<void> cacheProfile(MusicianHiveModel profile) {
    return _hiveService.saveMusicianProfile(profile);
  }

  @override
  Future<MusicianHiveModel?> getCachedProfileById(String id) async {
    return _hiveService.getMusicianProfileById(id);
  }

  @override
  Future<MusicianHiveModel?> getCachedProfileByUserId(String userId) async {
    return _hiveService.getMusicianProfileByUserId(userId);
  }

  @override
  Future<void> deleteCachedProfileById(String id) {
    return _hiveService.deleteMusicianProfileById(id);
  }

  @override
  Future<void> deleteCachedProfileByUserId(String userId) {
    return _hiveService.deleteMusicianProfileByUserId(userId);
  }
}
