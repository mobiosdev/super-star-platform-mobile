import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/platform_api.dart';
import '../models/fan_dto.dart';

final fanRepositoryProvider = Provider<FanRepository>((ref) {
  return FanRepository(ref.watch(platformApiProvider));
});

class FanRepository {
  FanRepository(this._api);
  final PlatformApi _api;

  Future<List<FanNotificationDto>> getNotifications({int page = 1, int limit = 20}) =>
      _api.getFanNotifications(page: page, limit: limit);

  Future<List<FanLiveArtistDto>> getLiveArtists() => _api.getFansLive();

  Future<void> markNotificationRead(String notificationId) =>
      _api.markFanNotificationRead(notificationId);
}
