import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/content_dto.dart';
import '../models/creator_studio_dto.dart';
import '../models/fan_dto.dart';
import '../models/moderation_dto.dart';
import '../models/superstar_dto.dart';
import '../models/user_dto.dart';

final platformApiProvider = Provider<PlatformApi>((ref) {
  return PlatformApi(ref.watch(dioClientProvider));
});

/// Typed HTTP client for SuperStar Platform REST API (Postman collection).
class PlatformApi {
  PlatformApi(this._client);

  final DioClient _client;

  // ——— Health ———
  Future<void> healthCheck() async => _client.get(ApiConstants.health);

  // ——— Auth ———
  Future<AuthTokensDto> login({required String email, required String password}) async {
    final response = await _client.post(
      ApiConstants.authLogin,
      data: {'email': email, 'password': password},
      options: Options(headers: {'Authorization': null}),
    );
    return _parseAuthTokens(response.data);
  }

  Future<AuthTokensDto> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final response = await _client.post(
      ApiConstants.authRegister,
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        if (phone != null) 'phone': phone,
      },
      options: Options(headers: {'Authorization': null}),
    );
    return _parseAuthTokens(response.data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _client.post(ApiConstants.authLogout, data: {'refresh_token': refreshToken});
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.post(
      ApiConstants.authForgotPassword,
      data: {'email': email},
      options: Options(headers: {'Authorization': null}),
    );
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _client.post(
      ApiConstants.authResetPassword,
      data: {'token': token, 'new_password': newPassword},
      options: Options(headers: {'Authorization': null}),
    );
  }

  // ——— Users ———
  Future<UserDto> getCurrentUser() async {
    final response = await _client.get(ApiConstants.usersMe);
    return UserDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<UserDto> updateCurrentUser(Map<String, dynamic> body) async {
    final response = await _client.patch(ApiConstants.usersMe, data: body);
    return UserDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<List<UserDto>> listUsers({
    String? role,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.users,
      query: {
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
        'page': page,
        'limit': limit,
      },
    );
    return _parseList(response.data, UserDto.fromJson);
  }

  // ——— Superstars ———
  Future<List<SuperstarDto>> listSuperstars({
    String? search,
    String? category,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.superstars,
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
        if (verified != null) 'verified': verified.toString(),
        'page': page,
        'limit': limit,
      },
    );
    return _parseList(response.data, SuperstarDto.fromJson);
  }

  Future<SuperstarDto> getSuperstar(String id) async {
    final response = await _client.get(ApiConstants.superstar(id));
    return SuperstarDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<List<PlanDto>> getSuperstarPlans(String superstarId) async {
    final response = await _client.get(ApiConstants.superstarPlans(superstarId));
    return _parseList(response.data, PlanDto.fromJson);
  }

  Future<SuperstarDto> updateSuperstar(String id, Map<String, dynamic> body) async {
    final response = await _client.patch(ApiConstants.superstar(id), data: body);
    return SuperstarDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  // ——— Content ———
  Future<ContentDto> createContent(Map<String, dynamic> body) async {
    final response = await _client.post(ApiConstants.content, data: body);
    return ContentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<ContentDto> uploadContentMedia({
    required String contentId,
    required String filePath,
    required String fileName,
    String mediaType = 'IMAGE',
    int position = 0,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'media_type': mediaType,
      'position': position,
    });
    final response = await _client.postFormData(
      ApiConstants.contentMedia(contentId),
      form,
    );
    return ContentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<List<ContentDto>> getFeed({
    required String superstarId,
    String? contentType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.feed(superstarId),
      query: {
        if (contentType != null) 'content_type': contentType,
        'page': page,
        'limit': limit,
      },
    );
    return _parseContentList(response.data);
  }

  Future<ContentDto> getContent(String contentId) async {
    final response = await _client.get(ApiConstants.contentById(contentId));
    return ContentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<ContentDto> updateContent(String contentId, Map<String, dynamic> body) async {
    final response = await _client.patch(ApiConstants.contentById(contentId), data: body);
    return ContentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<void> deleteContent(String contentId) async {
    await _client.delete(ApiConstants.contentById(contentId));
  }

  Future<List<ContentDto>> listSuperstarContent({
    required String superstarId,
    String? status,
    String? contentType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.superstarContent(superstarId),
      query: {
        if (status != null) 'status': status,
        if (contentType != null) 'content_type': contentType,
        'page': page,
        'limit': limit,
      },
    );
    return _parseContentList(response.data);
  }

  // ——— Subscriptions ———
  Future<List<SubscriptionDto>> getMySubscriptions() async {
    final response = await _client.get(ApiConstants.subscriptionsMe);
    return _parseList(response.data, SubscriptionDto.fromJson);
  }

  Future<Map<String, dynamic>> createCheckoutSession({
    required String planId,
    required String billingCycle,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final response = await _client.post(
      ApiConstants.subscriptionsCheckout,
      data: {
        'plan_id': planId,
        'billing_cycle': billingCycle,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      },
    );
    return ApiResponse.asMap(ApiResponse.unwrap(response.data));
  }

  Future<void> cancelSubscription(String subscriptionId, {String? reason}) async {
    final body = <String, dynamic>{};
    if (reason != null) body['reason'] = reason;
    await _client.post(ApiConstants.subscriptionCancel(subscriptionId), data: body);
  }

  // ——— Moderation ———
  Future<List<ModerationDto>> getModerationQueue({
    String status = 'PENDING',
    String? superstarId,
    String? contentType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.moderationQueue,
      query: {
        'status': status,
        if (superstarId != null) 'superstar_id': superstarId,
        if (contentType != null) 'content_type': contentType,
        'page': page,
        'limit': limit,
      },
    );
    return _parseList(response.data, ModerationDto.fromJson);
  }

  Future<void> claimModeration(String contentId) async {
    await _client.post(ApiConstants.moderationClaim(contentId));
  }

  Future<void> approveContent(String contentId, {String? note}) async {
    final body = <String, dynamic>{};
    if (note != null) body['note'] = note;
    await _client.post(ApiConstants.moderationApprove(contentId), data: body);
  }

  Future<void> rejectContent(
    String contentId, {
    String reasonCode = 'OTHER',
    required String reasonText,
  }) async {
    await _client.post(
      ApiConstants.moderationReject(contentId),
      data: {'reason_code': reasonCode, 'reason_text': reasonText},
    );
  }

  Future<void> appealContent(String contentId, {required String appealText}) async {
    await _client.post(
      ApiConstants.moderationAppeal(contentId),
      data: {'appeal_text': appealText},
    );
  }

  // ——— Engagement ———
  Future<void> toggleLike(String contentId) async {
    await _client.post(ApiConstants.contentLike(contentId));
  }

  Future<List<CommentDto>> getComments(String contentId, {int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.contentComments(contentId),
      query: {'page': page, 'limit': limit},
    );
    return _parseList(response.data, CommentDto.fromJson);
  }

  Future<CommentDto> addComment(
    String contentId, {
    required String body,
    String? parentId,
  }) async {
    final response = await _client.post(
      ApiConstants.contentComments(contentId),
      data: {'body': body, 'parent_id': parentId},
    );
    return CommentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<Map<String, dynamic>> createPoll({
    required String superstarId,
    required String question,
    required List<String> options,
    String tierRequired = 'SILVER',
    String? expiresAt,
  }) async {
    final response = await _client.post(
      ApiConstants.superstarPolls(superstarId),
      data: {
        'question': question,
        'options': options,
        'tier_required': tierRequired,
        if (expiresAt != null) 'expires_at': expiresAt,
      },
    );
    return ApiResponse.asMap(ApiResponse.unwrap(response.data));
  }

  Future<void> votePoll(String pollId, {required int optionIndex}) async {
    await _client.post(
      ApiConstants.pollVote(pollId),
      data: {'option_index': optionIndex},
    );
  }

  // ——— Messages ———
  Future<List<MessageDto>> getInbox({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.messagesInbox,
      query: {'page': page, 'limit': limit},
    );
    return _parseList(response.data, MessageDto.fromJson);
  }

  Future<MessageDto> sendMessage({
    required String recipientId,
    required String body,
    String? mediaUrl,
  }) async {
    final response = await _client.post(
      ApiConstants.messages,
      data: {
        'recipient_id': recipientId,
        'body': body,
        'media_url': mediaUrl,
      },
    );
    return MessageDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  // ——— Analytics ———
  Future<Map<String, dynamic>> getSuperstarAnalytics(
    String superstarId, {
    String period = '30d',
  }) async {
    final response = await _client.get(
      ApiConstants.analyticsSuperstarOverview(superstarId),
      query: {'period': period},
    );
    return ApiResponse.asMap(ApiResponse.unwrap(response.data));
  }

  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    final response = await _client.get(ApiConstants.analyticsPlatform);
    return ApiResponse.asMap(ApiResponse.unwrap(response.data));
  }

  // ——— Creator studio ———

  Future<CreatorStudioDashboardDto> getCreatorStudioDashboard({int periodDays = 30}) async {
    final response = await _client.get(
      ApiConstants.creatorStudioDashboard,
      query: {'period_days': periodDays},
    );
    return CreatorStudioDashboardDto.fromJson(
      ApiResponse.asMap(ApiResponse.unwrap(response.data)),
    );
  }

  Future<GoLiveResultDto> startGoLive({
    String? title,
    String? streamUrl,
    String? message,
  }) async {
    final body = <String, dynamic>{};
    if (title != null && title.isNotEmpty) body['title'] = title;
    if (streamUrl != null && streamUrl.isNotEmpty) body['stream_url'] = streamUrl;
    if (message != null && message.isNotEmpty) body['message'] = message;

    final response = await _client.post(
      ApiConstants.creatorStudioGoLive,
      data: body.isEmpty ? null : body,
    );
    return GoLiveResultDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
  }

  Future<void> endGoLive() async {
    await _client.post(ApiConstants.creatorStudioGoLiveEnd);
  }

  // ——— Fans ———

  Future<List<FanNotificationDto>> getFanNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.fansNotifications,
      query: {'page': page, 'limit': limit},
    );
    return _parseList(response.data, FanNotificationDto.fromJson);
  }

  Future<List<FanLiveArtistDto>> getFansLive() async {
    final response = await _client.get(ApiConstants.fansLive);
    return _parseList(response.data, FanLiveArtistDto.fromJson);
  }

  Future<void> markFanNotificationRead(String notificationId) async {
    await _client.patch(ApiConstants.fanNotificationRead(notificationId));
  }

  /// Resolve superstar profile id for the logged-in creator.
  Future<String?> resolveSuperstarId({String? userId, String? knownSuperstarId}) async {
    if (knownSuperstarId != null && knownSuperstarId.isNotEmpty) return knownSuperstarId;
    final stars = await listSuperstars(limit: 50);
    if (userId != null) {
      for (final s in stars) {
        if (s.userId == userId) return s.id;
      }
    }
    return stars.isNotEmpty ? stars.first.id : null;
  }

  AuthTokensDto _parseAuthTokens(dynamic body) {
    return AuthTokensDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(body)));
  }

  List<ContentDto> _parseContentList(dynamic body) {
    return _parseList(body, ContentDto.fromJson);
  }

  List<T> _parseList<T>(dynamic body, T Function(Map<String, dynamic>) fromJson) {
    final data = ApiResponse.unwrap(body);
    return ApiResponse.asList(data).map((e) => fromJson(ApiResponse.asMap(e))).toList();
  }
}
