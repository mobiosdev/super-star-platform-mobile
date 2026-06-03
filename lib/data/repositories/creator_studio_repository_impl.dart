import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/platform_api.dart';
import '../models/creator_studio_dto.dart';

final creatorStudioRepositoryProvider = Provider<CreatorStudioRepository>((ref) {
  return CreatorStudioRepository(ref.watch(platformApiProvider));
});

class CreatorStudioRepository {
  CreatorStudioRepository(this._api);
  final PlatformApi _api;

  Future<CreatorStudioDashboardDto> getDashboard({int periodDays = 30}) =>
      _api.getCreatorStudioDashboard(periodDays: periodDays);

  Future<GoLiveResultDto> startGoLive({
    String? title,
    String? streamUrl,
    String? message,
  }) =>
      _api.startGoLive(title: title, streamUrl: streamUrl, message: message);

  Future<void> endGoLive() => _api.endGoLive();
}
