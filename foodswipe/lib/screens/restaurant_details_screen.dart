import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/match_display.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildInfoSection(context),
                // Show matches section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.currentUserId == null) {
                      return SizedBox.shrink();
                    }
                    return MatchDisplay(
                      restaurant: restaurant,
                      currentUserId: authProvider.currentUserId!,
                    );
                  },
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            restaurant.imageUrl.isNotEmpty
                ? Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<RestaurantProvider>(
          builder: (context, provider, child) {
            final isFavorite = provider.likedRestaurants.any(
              (r) => r.id == restaurant.id,
            );
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                if (isFavorite) {
                  provider.unlikeRestaurant(restaurant);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed from favorites'),
                      duration: Duration(milliseconds: 1000),
                    ),
                  );
                } else {
                  provider.likeRestaurant(restaurant);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to favorites!'),
                      duration: Duration(milliseconds: 1000),
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.restaurant, size: 100, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24),
              SizedBox(width: 6),
              Text(
                '${restaurant.rating}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              Text('•', style: TextStyle(color: Colors.grey, fontSize: 18)),
              SizedBox(width: 16),
              Text(
                restaurant.cuisineType,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(width: 16),
              Text('•', style: TextStyle(color: Colors.grey, fontSize: 18)),
              SizedBox(width: 16),
              Text(
                restaurant.priceLevel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: restaurant.isOpen
                  ? Color(0xFF4ECDC4).withValues(alpha: 0.2)
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              restaurant.isOpen ? 'Open Now' : 'Closed',
              style: TextStyle(
                color: restaurant.isOpen ? Color(0xFF4ECDC4) : Colors.red[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Address',
            content: restaurant.address,
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.restaurant_menu,
            title: 'Cuisine',
            content: restaurant.cuisineType,
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money,
            title: 'Price Range',
            content: restaurant.priceLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
