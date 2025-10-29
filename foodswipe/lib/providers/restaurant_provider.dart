import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/restaurant.dart';
import '../services/google_places_api_key.dart';

class RestaurantProvider extends ChangeNotifier {
  final GooglePlacesService _placesService = GooglePlacesService();

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _availableRestaurants = [];
  List<Restaurant> _likedRestaurants = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;
  int _currentSwipeIndex = 0;

  List<Restaurant> get availableRestaurants => _availableRestaurants;
  List<Restaurant> get likedRestaurants => _likedRestaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoadedOnce => _hasLoadedOnce;
  int get currentSwipeIndex => _currentSwipeIndex;

  Future<void> loadRestaurants({bool forceRefresh = false}) async {
    if (_hasLoadedOnce && !forceRefresh) {
      print('Using cached restaurants');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading restaurants from API');

      Position position = await _determinePosition();
      print('User location: ${position.latitude}, ${position.longitude}');

      final restaurants = await _placesService.searchNearbyRestaurants(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
      );

      print('Loaded ${restaurants.length} restaurants from API');

      _allRestaurants = restaurants;

      _availableRestaurants = _allRestaurants
          .where((r) => !_likedRestaurants.any((liked) => liked.id == r.id))
          .toList();

      _hasLoadedOnce = true;
      _isLoading = false;
      _error = null;

      print('Available restaurants: ${_availableRestaurants.length}');
      print('Liked restaurants: ${_likedRestaurants.length}');

      notifyListeners();
    } catch (e) {
      print('Error loading restaurants: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void likeRestaurant(Restaurant restaurant) {
    if (!_likedRestaurants.any((r) => r.id == restaurant.id)) {
      _likedRestaurants.add(restaurant);
      print('Liked: ${restaurant.name} (Total: ${_likedRestaurants.length})');
    }

    _availableRestaurants.removeWhere((r) => r.id == restaurant.id);

    print('Remaining restaurants: ${_availableRestaurants.length}');
    notifyListeners();
  }

  void passRestaurant(Restaurant restaurant) {
    _availableRestaurants.removeWhere((r) => r.id == restaurant.id);

    print(
      'Passed: ${restaurant.name} (Remaining: ${_availableRestaurants.length})',
    );
    notifyListeners();
  }

  void updateSwipeIndex(int index) {
    _currentSwipeIndex = index;
  }

  void unlikeRestaurant(Restaurant restaurant) {
    _likedRestaurants.removeWhere((r) => r.id == restaurant.id);

    if (_allRestaurants.any((r) => r.id == restaurant.id) &&
        !_availableRestaurants.any((r) => r.id == restaurant.id)) {
      _availableRestaurants.add(restaurant);
    }

    print('Unliked: ${restaurant.name}');
    notifyListeners();
  }

  Future<void> refreshRestaurants() async {
    print('Refreshing restaurants');
    _hasLoadedOnce = false;
    await loadRestaurants(forceRefresh: true);
  }

  void clearAll() {
    _allRestaurants.clear();
    _availableRestaurants.clear();
    _likedRestaurants.clear();
    _hasLoadedOnce = false;
    _error = null;
    notifyListeners();
    print('Cleared all restaurant data');
  }

  int get currentIndex {
    final total = _allRestaurants.length;
    final remaining = _availableRestaurants.length;
    return total - remaining;
  }

  int get totalCount => _allRestaurants.length;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location services.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permissions are denied. Please grant location permissions.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }
}
