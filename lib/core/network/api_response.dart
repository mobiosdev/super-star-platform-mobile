/// Helpers for SuperStar API envelope: `{ "data": ... , "meta": ... }`.
abstract final class ApiResponse {
  static dynamic unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] != null) {
      return body['data'];
    }
    if (body is Map && body['data'] != null) {
      return body['data'];
    }
    return body;
  }

  static Map<String, dynamic>? unwrapMeta(dynamic body) {
    if (body is Map<String, dynamic> && body['meta'] is Map) {
      return Map<String, dynamic>.from(body['meta'] as Map);
    }
    if (body is Map && body['meta'] is Map) {
      return Map<String, dynamic>.from(body['meta'] as Map);
    }
    return null;
  }

  static List<dynamic> asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['items', 'results', 'content', 'queue', 'data', 'subscriptions']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return [];
  }

  static Map<String, dynamic> asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static bool hasMorePages(Map<String, dynamic>? meta, {required int itemCount, required int limit}) {
    if (meta == null) return itemCount >= limit;
    final total = meta['total'];
    final page = meta['page'];
    final pages = meta['total_pages'] ?? meta['totalPages'];
    if (pages is num) return (page is num ? page.toInt() : 1) < pages.toInt();
    if (total is num && page is num) {
      return page.toInt() * limit < total.toInt();
    }
    return itemCount >= limit;
  }
}
