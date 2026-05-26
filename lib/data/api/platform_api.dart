import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/content_dto.dart';
import '../models/moderation_dto.dart';
import '../models/user_dto.dart';

final platformApiProvider = Provider<PlatformApi>((ref) {
  return PlatformApi(ref.watch(dioClientProvider));
});

/// Typed HTTP client for SuperStar Platform REST API (Postman collection).
class PlatformApi {
  PlatformApi(this._client);

  final DioClient _client;

  // ——— Health ———

  Future<void> healthCheck() async {
    await _client.get(ApiConstants.health);
  }

  // ——— Auth ———

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
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
    await _client.post(
      ApiConstants.authLogout,
      data: {'refresh_token': refreshToken},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.post(
      ApiConstants.authForgotPassword,
      data: {'email': email},
      options: Options(headers: {'Authorization': null}),
    );
  }

  // ——— Users ———

  Future<UserDto> getCurrentUser() async {
    final response = await _client.get(ApiConstants.usersMe);
    final data = ApiResponse.unwrap(response.data);
    return UserDto.fromJson(ApiResponse.asMap(data));
  }

  Future<UserDto> updateCurrentUser(Map<String, dynamic> body) async {
    final response = await _client.patch(ApiConstants.usersMe, data: body);
    final data = ApiResponse.unwrap(response.data);
    return UserDto.fromJson(ApiResponse.asMap(data));
  }

  // ——— Superstars ———

  Future<List<Map<String, dynamic>>> listSuperstars({
    String? search,
    String? category,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiConstants.superstars,
      query: {
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (verified != null) 'verified': verified.toString(),
        'page': page,
        'limit': limit,
      },
      options: Options(headers: {'Authorization': null}),
    );
    return _asMapList(ApiResponse.unwrap(response.data), response.data);
  }

  Future<Map<String, dynamic>> getSuperstar(String id) async {
    final response = await _client.get(
      ApiConstants.superstar(id),
      options: Options(headers: {'Authorization': null}),
    );
    return ApiResponse.asMap(ApiResponse.unwrap(response.data));
  }

  // ——— Feed & content ———

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

  Future<List<SubscriptionDto>> getMySubscriptions() async {
    final response = await _client.get(ApiConstants.subscriptionsMe);
    final data = ApiResponse.unwrap(response.data);
    return ApiResponse.asList(data)
        .map((e) => SubscriptionDto.fromJson(ApiResponse.asMap(e)))
        .where((s) => s.superstarId.isNotEmpty)
        .toList();
  }

  Future<ContentDto> getContent(String contentId) async {
    final response = await _client.get(ApiConstants.contentById(contentId));
    return ContentDto.fromJson(ApiResponse.asMap(ApiResponse.unwrap(response.data)));
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
    final data = ApiResponse.unwrap(response.data);
    return ApiResponse.asList(data)
        .map((e) => ModerationDto.fromJson(ApiResponse.asMap(e)))
        .toList();
  }

  Future<void> claimModeration(String contentId) async {
    await _client.post(ApiConstants.moderationClaim(contentId));
  }

  Future<void> approveContent(String contentId, {String? note}) async {
    final body = <String, dynamic>{};
    if (note != null) body['note'] = note;
    await _client.post(
      ApiConstants.moderationApprove(contentId),
      data: body,
    );
  }

  Future<void> rejectContent(
    String contentId, {
    String reasonCode = 'OTHER',
    required String reasonText,
  }) async {
    await _client.post(
      ApiConstants.moderationReject(contentId),
      data: {
        'reason_code': reasonCode,
        'reason_text': reasonText,
      },
    );
  }

  // ——— Engagement ———

  Future<void> toggleLike(String contentId) async {
    await _client.post(ApiConstants.contentLike(contentId));
  }

  // ——— Subscriptions checkout ———

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

  AuthTokensDto _parseAuthTokens(dynamic body) {
    final data = ApiResponse.asMap(ApiResponse.unwrap(body));
    return AuthTokensDto.fromJson(data);
  }

  List<ContentDto> _parseContentList(dynamic body) {
    final data = ApiResponse.unwrap(body);
    return ApiResponse.asList(data)
        .map((e) => ContentDto.fromJson(ApiResponse.asMap(e)))
        .toList();
  }

  List<Map<String, dynamic>> _asMapList(dynamic data, dynamic rawBody) {
    final list = ApiResponse.asList(data);
    if (list.isNotEmpty) {
      return list.map((e) => ApiResponse.asMap(e)).toList();
    }
    final meta = ApiResponse.unwrapMeta(rawBody);
    if (meta != null && meta['items'] is List) {
      return (meta['items'] as List).map((e) => ApiResponse.asMap(e)).toList();
    }
    return [];
  }
}
