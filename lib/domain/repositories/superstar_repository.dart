import '../../data/models/superstar_dto.dart';

abstract class SuperstarRepository {
  Future<List<SuperstarDto>> list({
    String? search,
    String? category,
    bool? verified,
    int page,
    int limit,
  });
  Future<SuperstarDto> getById(String id);
  Future<List<PlanDto>> getPlans(String superstarId);
  Future<String?> resolveMySuperstarId({String? userId, String? superstarId});
}
