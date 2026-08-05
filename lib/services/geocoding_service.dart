import 'dart:convert';

import 'package:http/http.dart' as http;

class CitySearchResult {
  final String displayName;
  final String? countryCode;
  final double latitude;
  final double longitude;

  const CitySearchResult({
    required this.displayName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });
}

/// Looks up city/place coordinates using the free OpenStreetMap Nominatim
/// API. No API key or backend of our own required. Only used when the user
/// searches for a city; day-to-day prayer time calculation stays fully
/// offline once a location is picked.
class GeocodingService {
  static const _endpoint = 'https://nominatim.openstreetmap.org/search';

  Future<List<CitySearchResult>> search(String query, {String? language}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'q': trimmed,
      'format': 'jsonv2',
      'limit': '8',
      'addressdetails': '1',
      'accept-language': ?language,
    });

    final response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'PrayerQiblaApp/1.0 (+https://github.com/ojgWeza/prayer-qibla-app)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Geocoding request failed (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((raw) {
      final item = raw as Map<String, dynamic>;
      final address = item['address'] as Map<String, dynamic>?;
      final city = address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['state'] ??
          item['name'];
      final country = address?['country'];
      final label = [city, country].whereType<String>().join('، ');
      return CitySearchResult(
        displayName: label.isNotEmpty ? label : (item['display_name'] as String),
        countryCode: address?['country_code'] as String?,
        latitude: double.parse(item['lat'] as String),
        longitude: double.parse(item['lon'] as String),
      );
    }).toList();
  }
}
