import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Search radius in meters
  int _searchRadius = 5000;

  // Price levels (0=Free, 1=$, 2=$$, 3=$$$, 4=$$$$)
  int? _minPrice;
  int? _maxPrice;

  // Selected cuisine types
  final Set<String> _selectedCuisines = {};

  // Getters
  int get searchRadius => _searchRadius;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  Set<String> get selectedCuisines => _selectedCuisines;

  // Get radius in km for display
  String get searchRadiusDisplay {
    if (_searchRadius < 1000) {
      return '$_searchRadius m';
    } else {
      return '${(_searchRadius / 1000).toStringAsFixed(0)} km';
    }
  }

  // Get price range display
  String get priceRangeDisplay {
    if (_minPrice == null && _maxPrice == null) {
      return 'All prices';
    }
    if (_minPrice != null && _maxPrice != null) {
      return '${_getPriceSymbol(_minPrice!)} - ${_getPriceSymbol(_maxPrice!)}';
    }
    if (_minPrice != null) {
      return '${_getPriceSymbol(_minPrice!)}+';
    }
    return 'Up to ${_getPriceSymbol(_maxPrice!)}';
  }

  // Get cuisine display
  String get cuisineDisplay {
    if (_selectedCuisines.isEmpty) {
      return 'All cuisines';
    }
    if (_selectedCuisines.length == 1) {
      return _selectedCuisines.first;
    }
    return '${_selectedCuisines.length} selected';
  }

  String _getPriceSymbol(int level) {
    switch (level) {
      case 0:
        return 'Free';
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return '\$\$';
    }
  }

  // Setters
  void setSearchRadius(int radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  void setPriceRange({int? minPrice, int? maxPrice}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  void toggleCuisine(String cuisine) {
    if (_selectedCuisines.contains(cuisine)) {
      _selectedCuisines.remove(cuisine);
    } else {
      _selectedCuisines.add(cuisine);
    }
    notifyListeners();
  }

  void clearCuisines() {
    _selectedCuisines.clear();
    notifyListeners();
  }

  void resetFilters() {
    _searchRadius = 5000;
    _minPrice = null;
    _maxPrice = null;
    _selectedCuisines.clear();
    notifyListeners();
  }

  // Check if filters are active
  bool get hasActiveFilters {
    return _minPrice != null ||
           _maxPrice != null ||
           _selectedCuisines.isNotEmpty ||
           _searchRadius != 5000;
  }
}
