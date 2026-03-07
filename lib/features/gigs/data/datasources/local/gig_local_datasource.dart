import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/gigs/data/models/gig_hive_model.dart';

final gigLocalDataSourceProvider = Provider<IGigLocalDataSource>((ref) {
  return GigLocalDataSource(ref.read(hiveServiceProvider));
});

abstract interface class IGigLocalDataSource {
  Future<void> saveGigs(List<GigHiveModel> gigs, {bool replace = true});
  Future<void> upsertGig(GigHiveModel gig);
  Future<List<GigHiveModel>> getGigs({String? organizerId});
  Future<GigHiveModel?> getGigById(String id);
  Future<void> deleteGig(String id);
}

class GigLocalDataSource implements IGigLocalDataSource {
  final HiveService _hiveService;

  GigLocalDataSource(this._hiveService);

  @override
  Future<void> saveGigs(List<GigHiveModel> gigs, {bool replace = true}) {
    return _hiveService.saveGigs(gigs, replace: replace);
  }

  @override
  Future<void> upsertGig(GigHiveModel gig) {
    return _hiveService.upsertGig(gig);
  }

  @override
  Future<List<GigHiveModel>> getGigs({String? organizerId}) async {
    return _hiveService.getGigs(organizerId: organizerId);
  }

  @override
  Future<GigHiveModel?> getGigById(String id) async {
    return _hiveService.getGigById(id);
  }

  @override
  Future<void> deleteGig(String id) {
    return _hiveService.deleteGig(id);
  }
}
