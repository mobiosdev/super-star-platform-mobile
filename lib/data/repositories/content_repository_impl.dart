import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/content_repository.dart';
import '../api/platform_api.dart';
import '../models/content_dto.dart';
import '../../core/demo/hardcoded_feed_videos.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(ref.watch(platformApiProvider));
});

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._api);
  final PlatformApi _api;

  @override
  Future<ContentDto> create({
    required String title,
    required String body,
    required String contentType,
    required String tierRequired,
    List<String>? tags,
    bool isDownloadable = false,
  }) =>
      _api.createContent({
        'title': title,
        'body': body,
        'content_type': contentType,
        'tier_required': tierRequired,
        'is_downloadable': isDownloadable,
        'scheduled_at': null,
        if (tags != null) 'tags': tags,
      });

  @override
  Future<ContentDto> uploadMedia({
    required String contentId,
    required String filePath,
    required String fileName,
    String mediaType = 'IMAGE',
  }) =>
      _api.uploadContentMedia(
        contentId: contentId,
        filePath: filePath,
        fileName: fileName,
        mediaType: mediaType,
      );

  @override
  Future<ContentDto> getById(String id) async {
    final hardcoded = HardcodedFeedVideos.contentById(id);
    if (hardcoded != null) return hardcoded;
    return _api.getContent(id);
  }

  @override
  Future<List<ContentDto>> getFeed({
    required String superstarId,
    int page = 1,
    int limit = 20,
  }) =>
      _api.getFeed(superstarId: superstarId, page: page, limit: limit);

  @override
  Future<List<ContentDto>> listForSuperstar({
    required String superstarId,
    String? status,
    int page = 1,
    int limit = 20,
  }) =>
      _api.listSuperstarContent(
        superstarId: superstarId,
        status: status,
        page: page,
        limit: limit,
      );

  @override
  Future<void> delete(String id) => _api.deleteContent(id);
}
