abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.superstar.app/v1',
  );
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refresh = '/auth/refresh';

  // Content
  static const String content = '/content';
  static const String contentSubmit = '/content/submit';

  // Feed
  static const String feed = '/feed';

  // Moderation
  static const String moderationQueue = '/moderation/queue';
  static const String moderationApprove = '/moderation/approve';
  static const String moderationReject = '/moderation/reject';

  // Subscriptions
  static const String subscriptions = '/subscriptions';

  // WebSocket
  static const String moderationWs = '/ws/moderation';
}
