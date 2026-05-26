/// Compile-time API configuration (`--dart-define=API_BASE_URL=...`).
abstract final class EnvConfig {
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://super-star-platform-backend.onrender.com/v1',
  );

  static const bool useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

  /// Normalized base URL without trailing slash or stray whitespace.
  static String get apiBaseUrl {
    var url = _rawBaseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static String path(String endpoint) {
    final ep = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return ep;
  }

  static String fullUrl(String endpoint) => '${apiBaseUrl}${path(endpoint)}';
}
