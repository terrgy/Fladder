import 'package:fladder/models/items/images_models.dart';

const _tmdbPosterBaseUrl = 'https://image.tmdb.org/t/p/w500';
const _tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/w780';

bool _hasHttpScheme(String url) {
  final lower = url.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

String? tmdbUrl(String base, String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  if (_hasHttpScheme(trimmed)) return trimmed;
  return '$base$trimmed';
}

String? resolveImageUrl({
  required String? path,
  String? serverUrl,
  String tmdbBase = _tmdbPosterBaseUrl,
}) {
  if (path == null || path.trim().isEmpty) return path;
  final trimmed = path.trim();

  if (_hasHttpScheme(trimmed)) {
    return trimmed;
  }

  final tmdb = tmdbUrl(tmdbBase, trimmed);
  if (tmdb != null) return tmdb;

  return resolveServerUrl(path: trimmed, serverUrl: serverUrl);
}

String? resolveServerUrl({required String? path, required String? serverUrl}) {
  if (path == null || path.trim().isEmpty) return path;
  final trimmed = path.trim();

  if (_hasHttpScheme(trimmed)) {
    return trimmed;
  }

  if (serverUrl == null || serverUrl.trim().isEmpty) return trimmed;
  final cleanServerUrl = serverUrl.trim();

  final needsSlash = !cleanServerUrl.endsWith('/') && !trimmed.startsWith('/');
  return '$cleanServerUrl${needsSlash ? '/' : ''}$trimmed';
}

/// Builds a Seerr image-proxy URL for a TMDB image path.
///
/// When [serverUrl] is provided the resulting URL routes through Seerr's
/// built-in image cache/proxy (`/imageproxy/tmdb/t/p/<size><path>`),
/// which is required in environments where clients cannot reach the TMDB
/// CDN directly.
///
/// [tmdbSizePath] is the TMDB size segment without leading or trailing
/// slashes, e.g. `'t/p/w500'`, `'t/p/original'`, or `'t/p/w185'`.
///
/// Falls back to a direct TMDB CDN URL when [serverUrl] is absent.
String? seerrProxyImageUrl({
  required String? path,
  required String tmdbSizePath,
  String? serverUrl,
}) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  // Already an absolute URL – return as-is (covers both proxy and direct CDN).
  if (_hasHttpScheme(trimmed)) return trimmed;

  // Relative imageproxy path already constructed (e.g. /imageproxy/tmdb/...).
  if (trimmed.startsWith('/imageproxy/')) {
    return resolveServerUrl(path: trimmed, serverUrl: serverUrl);
  }

  // Regular TMDB relative path (e.g. /abc123.jpg).
  if (serverUrl != null && serverUrl.trim().isNotEmpty) {
    final cleanBase = serverUrl.trim().endsWith('/')
        ? serverUrl.trim().substring(0, serverUrl.trim().length - 1)
        : serverUrl.trim();
    return '$cleanBase/imageproxy/tmdb/$tmdbSizePath$trimmed';
  }

  // No server URL available – fall back to direct TMDB CDN URL.
  return 'https://image.tmdb.org/$tmdbSizePath$trimmed';
}

ImageData? tmdbPrimaryImage({required String keyPrefix, required String? posterPath}) {
  final url = tmdbUrl(_tmdbPosterBaseUrl, posterPath);
  if (url == null) return null;
  return ImageData(path: url, key: '${keyPrefix}_primary');
}

List<ImageData>? tmdbBackdropImages({required String keyPrefix, required String? backdropPath}) {
  final url = tmdbUrl(_tmdbBackdropBaseUrl, backdropPath);
  if (url == null) return null;
  return [ImageData(path: url, key: '${keyPrefix}_backdrop')];
}
