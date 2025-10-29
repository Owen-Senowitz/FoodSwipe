class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String priceLevel;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> types;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.priceLevel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.types,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    String photoReference = '';
    if (json['photos'] != null && json['photos'].isNotEmpty) {
      photoReference = json['photos'][0]['photo_reference'] ?? '';
    }

    int priceLevel = json['price_level'] ?? 2;
    String price = '\$' * (priceLevel > 0 ? priceLevel : 2);

    String address = json['vicinity'] ?? json['formatted_address'] ?? '';

    double lat = 0.0;
    double lng = 0.0;
    if (json['geometry'] != null && json['geometry']['location'] != null) {
      lat = (json['geometry']['location']['lat'] ?? 0.0).toDouble();
      lng = (json['geometry']['location']['lng'] ?? 0.0).toDouble();
    }

    List<String> types = [];
    if (json['types'] != null) {
      types = List<String>.from(json['types']);
    }

    bool isOpen = true;
    if (json['opening_hours'] != null &&
        json['opening_hours']['open_now'] != null) {
      isOpen = json['opening_hours']['open_now'];
    }

    return Restaurant(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: photoReference,
      rating: (json['rating'] ?? 0.0).toDouble(),
      priceLevel: price,
      address: address,
      latitude: lat,
      longitude: lng,
      types: types,
      isOpen: isOpen,
    );
  }

  String get cuisineType {
    for (var type in types) {
      if (type == 'restaurant') continue;
      if (type == 'food') continue;
      if (type == 'point_of_interest') continue;
      if (type == 'establishment') continue;

      return type
          .replaceAll('_', ' ')
          .split(' ')
          .map(
            (word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
          )
          .join(' ');
    }
    return 'Restaurant';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'priceLevel': priceLevel,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'types': types,
      'isOpen': isOpen,
    };
  }
}
