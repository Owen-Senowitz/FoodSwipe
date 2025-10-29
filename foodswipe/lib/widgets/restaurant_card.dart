import 'package:flutter/material.dart';
import 'package:foodswipe/models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            _buildImage(),

            // Gradient Overlay
            _buildGradientOverlay(),

            // Restaurant Info
            _buildRestaurantInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Positioned.fill(
      child: restaurant.imageUrl.isNotEmpty
          ? Image.network(
              restaurant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholder();
              },
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey[500]),
          SizedBox(height: 16),
          Text(
            restaurant.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name
            Text(
              restaurant.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),

            // Rating, Cuisine, Price
            Row(
              children: [
                // Rating
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '${restaurant.rating}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 12),

                // Separator
                Text(
                  '•',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 12),

                // Cuisine
                Text(
                  restaurant.cuisineType,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 12),

                // Separator
                Text(
                  '•',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 12),

                // Price
                Text(
                  restaurant.priceLevel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Address and Status
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                // Status
                Text(
                  '•',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(width: 8),
                Text(
                  restaurant.isOpen ? 'Open until 10 PM' : 'Closed',
                  style: TextStyle(
                    color: restaurant.isOpen
                        ? Color(0xFF4ECDC4)
                        : Colors.red[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
