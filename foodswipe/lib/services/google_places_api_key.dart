import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant.dart';

class GooglePlacesService {
  String get apiKey => dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? '';

  // Search for nearby restaurants
  Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 5000, // meters (about 3 miles)
    String? keyword,
    int? minPrice, // 0-4
    int? maxPrice, // 0-4
  }) async {
    try {
      // Validate API key
      if (apiKey.isEmpty) {
        throw Exception('Google Cloud API key not found in .env file');
      }

      // Build query parameters
      Map<String, String> queryParams = {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'type': 'restaurant',
        'key': apiKey,
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      if (minPrice != null) {
        queryParams['minprice'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['maxprice'] = maxPrice.toString();
      }

      // Build URL
      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        queryParams,
      );

      print('URL: $url');

      // Make API call
      final response = await http.get(url).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('API Status: ${data['status']}');

        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          print('Found ${results.length} restaurants');

          List<Restaurant> restaurants = [];

          for (var json in results) {
            try {
              var restaurant = Restaurant.fromJson(json);

              // Get full photo URL if photo exists
              if (restaurant.imageUrl.isNotEmpty) {
                String photoUrl = getPhotoUrl(restaurant.imageUrl);

                // Create new restaurant with full photo URL
                restaurant = Restaurant(
                  id: restaurant.id,
                  name: restaurant.name,
                  imageUrl: photoUrl,
                  rating: restaurant.rating,
                  priceLevel: restaurant.priceLevel,
                  address: restaurant.address,
                  latitude: restaurant.latitude,
                  longitude: restaurant.longitude,
                  types: restaurant.types,
                  isOpen: restaurant.isOpen,
                );
              }

              restaurants.add(restaurant);
            } catch (e) {
              print('Error parsing restaurant: $e');
            }
          }

          return restaurants;
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('No restaurants found in this area');
          return [];
        } else {
          throw Exception('API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchNearbyRestaurants: $e');
      rethrow;
    }
  }

  // Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) return '';

    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }

  // Get restaurant details by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
            'place_id': placeId,
            'fields':
                'name,rating,formatted_phone_number,formatted_address,'
                'opening_hours,price_level,photos,geometry,types,website',
            'key': apiKey,
          });

      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          throw Exception('Failed to load details: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPlaceDetails: $e');
      rethrow;
    }
  }

  // Text search for restaurants
  Future<List<Restaurant>> searchRestaurants({
    required String query,
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/place/textsearch/json', {
            'query': '$query restaurants',
            'location': '$latitude,$longitude',
            'radius': radius.toString(),
            'key': apiKey,
          });

      print('Searching for: $query');

      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          List<Restaurant> restaurants = [];

          for (var json in results) {
            var restaurant = Restaurant.fromJson(json);

            if (restaurant.imageUrl.isNotEmpty) {
              restaurant = Restaurant(
                id: restaurant.id,
                name: restaurant.name,
                imageUrl: getPhotoUrl(restaurant.imageUrl),
                rating: restaurant.rating,
                priceLevel: restaurant.priceLevel,
                address: restaurant.address,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                types: restaurant.types,
                isOpen: restaurant.isOpen,
              );
            }

            restaurants.add(restaurant);
          }

          return restaurants;
        } else {
          return [];
        }
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchRestaurants: $e');
      rethrow;
    }
  }
}
