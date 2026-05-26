import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/message_repository.dart';
import '../api/platform_api.dart';
import '../models/superstar_dto.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(ref.watch(platformApiProvider));
});

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._api);
  final PlatformApi _api;

  @override
  Future<List<MessageDto>> getInbox({int page = 1, int limit = 20}) =>
      _api.getInbox(page: page, limit: limit);

  @override
  Future<MessageDto> send({
    required String recipientId,
    required String body,
    String? mediaUrl,
  }) =>
      _api.sendMessage(recipientId: recipientId, body: body, mediaUrl: mediaUrl);
}
