import '../../data/models/content_dto.dart';

abstract class ContentRepository {
  Future<ContentDto> create({
    required String title,
    required String body,
    required String contentType,
    required String tierRequired,
    List<String>? tags,
    bool isDownloadable,
  });

  Future<ContentDto> uploadMedia({
    required String contentId,
    required String filePath,
    required String fileName,
    String mediaType,
  });

  Future<ContentDto> getById(String id);
  Future<List<ContentDto>> getFeed({required String superstarId, int page, int limit});
  Future<List<ContentDto>> listForSuperstar({
    required String superstarId,
    String? status,
    int page,
    int limit,
  });
  Future<void> delete(String id);
}
