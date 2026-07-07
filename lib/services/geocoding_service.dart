import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Convert latitude/longitude to Vietnamese address
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
          'accept-language': 'vi',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'WasteCollectionApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _formatVietnameseAddress(data);
      }
      return null;
    } catch (e) {
      // Silently fail - return null instead of throwing
      return null;
    }
  }

  /// Search for addresses matching query (for autocomplete)
  static Future<List<AddressSearchResult>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
          'countrycodes': 'vn',
          'accept-language': 'vi',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'WasteCollectionApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AddressSearchResult(
          displayName: item['display_name'] ?? '',
          lat: double.tryParse(item['lat'] ?? '0') ?? 0,
          lon: double.tryParse(item['lon'] ?? '0') ?? 0,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static String? _formatVietnameseAddress(Map<String, dynamic> data) {
    final addressData = data['address'];
    if (addressData == null) {
      return data['display_name'] as String?;
    }

    // Ensure address is a Map
    if (addressData is! Map) {
      return data['display_name'] as String?;
    }

    final address = Map<String, dynamic>.from(addressData);
    final parts = <String>[];
    
    // Try to get Vietnamese address components in order
    final houseNumber = address['house_number'] ?? '';
    final road = address['road'] ?? address['street'] ?? '';
    
    // Ward/Commune
    final ward = address['neighbourhood'] ?? 
                  address['suburb'] ?? 
                  address['quarter'] ?? 
                  address['ward'] ?? '';
    
    // District
    final district = address['city_district'] ?? 
                     address['county'] ?? 
                     address['district'] ?? '';
    
    // City/Province
    final city = address['city'] ?? 
                 address['province'] ?? 
                 address['state'] ?? '';

    // Build address from specific to general
    if (houseNumber.isNotEmpty && road.isNotEmpty) {
      parts.add('$houseNumber $road');
    } else if (road.isNotEmpty) {
      parts.add(road);
    }
    
    if (ward.isNotEmpty && ward != road) {
      parts.add(ward);
    }
    
    if (district.isNotEmpty) {
      parts.add(district);
    }
    
    if (city.isNotEmpty) {
      parts.add(city);
    }

    if (parts.isEmpty) {
      final displayName = data['display_name'];
      return displayName is String ? displayName : null;
    }

    return parts.join(', ');
  }
}

class AddressSearchResult {
  final String displayName;
  final double lat;
  final double lon;

  AddressSearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  String get shortAddress {
    final parts = displayName.split(', ');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return displayName;
  }
}
