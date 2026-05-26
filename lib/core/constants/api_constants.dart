import '../config/env_config.dart';

/// REST paths aligned with `postman/SuperStar_Platform_API.postman_collection.json`.
abstract final class ApiConstants {
  /// Override at build/run time: `--dart-define=API_BASE_URL=http://10.0.2.2:3000/v1`
  static String get baseUrl => EnvConfig.apiBaseUrl;

  /// Set `USE_MOCK_API=true` to use in-memory demo data without a backend.
  static bool get useMockApi => EnvConfig.useMockApi;

  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Health
  static const String health = '/health';

  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // Users
  static const String usersMe = '/users/me';
  static const String users = '/users';

  // Superstars
  static const String superstars = '/superstars';
  static String superstar(String id) => '/superstars/$id';
  static String superstarPlans(String id) => '/superstars/$id/plans';
  static String superstarContent(String id) => '/superstars/$id/content';
  static String superstarAvatar(String id) => '/superstars/$id/avatar';
  static String superstarCover(String id) => '/superstars/$id/cover';
  static String superstarPolls(String id) => '/superstars/$id/polls';

  // Content & feed
  static const String content = '/content';
  static String contentById(String id) => '/content/$id';
  static String contentMedia(String id) => '/content/$id/media';
  static String feed(String superstarId) => '/feed/$superstarId';
  static String contentLike(String id) => '/content/$id/like';
  static String contentComments(String id) => '/content/$id/comments';

  // Moderation
  static const String moderationQueue = '/moderation/queue';
  static const String moderationBulk = '/moderation/bulk';
  static String moderationClaim(String contentId) => '/moderation/$contentId/claim';
  static String moderationApprove(String contentId) => '/moderation/$contentId/approve';
  static String moderationReject(String contentId) => '/moderation/$contentId/reject';
  static String moderationAppeal(String contentId) => '/moderation/$contentId/appeal';

  // Subscriptions
  static const String subscriptionsCheckout = '/subscriptions/checkout';
  static const String subscriptionsMe = '/subscriptions/me';
  static String subscriptionCancel(String id) => '/subscriptions/$id/cancel';
  static String subscriptionChangePlan(String id) => '/subscriptions/$id/change-plan';

  // Engagement
  static String pollVote(String pollId) => '/polls/$pollId/vote';

  // Messages
  static const String messages = '/messages';
  static const String messagesInbox = '/messages/inbox';

  // Analytics
  static String analyticsSuperstarOverview(String id) => '/analytics/superstars/$id/overview';
  static String analyticsContent(String id) => '/analytics/content/$id';
  static const String analyticsPlatform = '/analytics/platform';

  // Webhooks (server-side only)
  static const String webhooksStripe = '/webhooks/stripe';
}
