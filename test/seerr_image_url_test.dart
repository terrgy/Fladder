import 'package:fladder/models/seerr/seerr_item_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seerrProxyImageUrl', () {
    const serverUrl = 'https://seerr.example.com';
    const serverUrlWithSlash = 'https://seerr.example.com/';
    const tmdbSize = 't/p/w500';
    const imagePath = '/kIBK5SKwgqIIuRKhhWrJn3XkbPq.jpg';

    test('returns null for null path', () {
      expect(seerrProxyImageUrl(path: null, tmdbSizePath: tmdbSize, serverUrl: serverUrl), isNull);
    });

    test('returns null for empty path', () {
      expect(seerrProxyImageUrl(path: '', tmdbSizePath: tmdbSize, serverUrl: serverUrl), isNull);
      expect(seerrProxyImageUrl(path: '   ', tmdbSizePath: tmdbSize, serverUrl: serverUrl), isNull);
    });

    test('builds Seerr proxy URL from TMDB path when serverUrl provided', () {
      final result = seerrProxyImageUrl(path: imagePath, tmdbSizePath: tmdbSize, serverUrl: serverUrl);
      expect(result, equals('https://seerr.example.com/imageproxy/tmdb/t/p/w500$imagePath'));
    });

    test('builds Seerr proxy URL and strips trailing slash from serverUrl', () {
      final result =
          seerrProxyImageUrl(path: imagePath, tmdbSizePath: tmdbSize, serverUrl: serverUrlWithSlash);
      expect(result, equals('https://seerr.example.com/imageproxy/tmdb/t/p/w500$imagePath'));
    });

    test('falls back to direct TMDB URL when no serverUrl', () {
      final result = seerrProxyImageUrl(path: imagePath, tmdbSizePath: tmdbSize, serverUrl: null);
      expect(result, equals('https://image.tmdb.org/t/p/w500$imagePath'));
    });

    test('falls back to direct TMDB URL when serverUrl is empty', () {
      final result = seerrProxyImageUrl(path: imagePath, tmdbSizePath: tmdbSize, serverUrl: '');
      expect(result, equals('https://image.tmdb.org/t/p/w500$imagePath'));
    });

    test('returns absolute URL as-is (already proxied)', () {
      const proxyUrl = 'https://seerr.example.com/imageproxy/tmdb/t/p/w500/abc.jpg';
      expect(
        seerrProxyImageUrl(path: proxyUrl, tmdbSizePath: tmdbSize, serverUrl: serverUrl),
        equals(proxyUrl),
      );
    });

    test('returns absolute TMDB CDN URL as-is', () {
      const tmdbAbsUrl = 'https://image.tmdb.org/t/p/w500/abc.jpg';
      expect(
        seerrProxyImageUrl(path: tmdbAbsUrl, tmdbSizePath: tmdbSize, serverUrl: serverUrl),
        equals(tmdbAbsUrl),
      );
    });

    test('prepends serverUrl for relative imageproxy path', () {
      const relativeProxy = '/imageproxy/tmdb/t/p/w500/abc.jpg';
      expect(
        seerrProxyImageUrl(path: relativeProxy, tmdbSizePath: tmdbSize, serverUrl: serverUrl),
        equals('https://seerr.example.com/imageproxy/tmdb/t/p/w500/abc.jpg'),
      );
    });

    test('returns relative imageproxy path unchanged when no serverUrl', () {
      const relativeProxy = '/imageproxy/tmdb/t/p/w500/abc.jpg';
      expect(
        seerrProxyImageUrl(path: relativeProxy, tmdbSizePath: tmdbSize, serverUrl: null),
        equals(relativeProxy),
      );
    });

    test('works with original size path', () {
      final result = seerrProxyImageUrl(
        path: imagePath,
        tmdbSizePath: 't/p/original',
        serverUrl: serverUrl,
      );
      expect(result, equals('https://seerr.example.com/imageproxy/tmdb/t/p/original$imagePath'));
    });

    test('trims whitespace from path', () {
      final result = seerrProxyImageUrl(
        path: '  $imagePath  ',
        tmdbSizePath: tmdbSize,
        serverUrl: serverUrl,
      );
      expect(result, equals('https://seerr.example.com/imageproxy/tmdb/t/p/w500$imagePath'));
    });
  });
}
