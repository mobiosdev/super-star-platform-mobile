import '../../data/models/superstar_dto.dart';

abstract class MessageRepository {
  Future<List<MessageDto>> getInbox({int page, int limit});
  Future<MessageDto> send({
    required String recipientId,
    required String body,
    String? mediaUrl,
  });
}
