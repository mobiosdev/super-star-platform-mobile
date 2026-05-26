import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage.dart';
import '../../domain/repositories/superstar_repository.dart';
import '../api/platform_api.dart';
import '../models/superstar_dto.dart';

final superstarRepositoryProvider = Provider<SuperstarRepository>((ref) {
  return SuperstarRepositoryImpl(
    ref.watch(platformApiProvider),
    ref.watch(localStorageProvider),
  );
});

class SuperstarRepositoryImpl implements SuperstarRepository {
  SuperstarRepositoryImpl(this._api, this._storage);

  final PlatformApi _api;
  final LocalStorage _storage;

  @override
  Future<List<SuperstarDto>> list({
    String? search,
    String? category,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) =>
      _api.listSuperstars(
        search: search,
        category: category,
        verified: verified,
        page: page,
        limit: limit,
      );

  @override
  Future<SuperstarDto> getById(String id) => _api.getSuperstar(id);

  @override
  Future<List<PlanDto>> getPlans(String superstarId) => _api.getSuperstarPlans(superstarId);

  @override
  Future<String?> resolveMySuperstarId({String? userId, String? superstarId}) async {
    final cached = _storage.getSuperstarId() ?? superstarId;
    if (cached != null && cached.isNotEmpty) return cached;
    final resolved = await _api.resolveSuperstarId(
      userId: userId ?? _storage.getUserId(),
      knownSuperstarId: superstarId,
    );
    if (resolved != null) await _storage.saveSuperstarId(resolved);
    return resolved;
  }
}
