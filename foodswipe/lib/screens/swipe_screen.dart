import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:foodswipe/providers/restaurant_provider.dart';
import 'package:foodswipe/widgets/restaurant_card.dart';
import 'package:provider/provider.dart';

class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with AutomaticKeepAliveClientMixin {
  CardSwiperController? _swiperController;
  bool _isProcessingSwipe = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();

    // Load restaurants when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants();
    });
  }

  @override
  void dispose() {
    _swiperController?.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // Prevent multiple swipes at once
    if (_isProcessingSwipe) {
      return false;
    }

    final provider = context.read<RestaurantProvider>();
    final restaurants = provider.availableRestaurants;

    // Validate index
    if (previousIndex < 0 || previousIndex >= restaurants.length) {
      return false;
    }

    _isProcessingSwipe = true;

    final restaurant = restaurants[previousIndex];

    // Process the swipe
    try {
      if (direction == CardSwiperDirection.right) {
        provider.likeRestaurant(restaurant);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Added ${restaurant.name}!')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (direction == CardSwiperDirection.left) {
        provider.passRestaurant(restaurant);
      }
    } catch (e) {
      print('Error processing swipe: $e');
    } finally {
      // Reset the flag after a short delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isProcessingSwipe = false;
          });
        }
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        return _buildBody(provider);
      },
    );
  }

  Widget _buildBody(RestaurantProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            SizedBox(height: 24),
            Text(
              'Finding delicious restaurants...',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => provider.refreshRestaurants(),
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.availableRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 100, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              'No more restaurants!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              provider.likedRestaurants.isEmpty
                  ? 'Try loading more restaurants'
                  : 'You\'ve reviewed ${provider.totalCount} restaurants!',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            SizedBox(height: 16),
            if (provider.likedRestaurants.isNotEmpty)
              Text(
                '❤️ ${provider.likedRestaurants.length} favorites saved',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.refreshRestaurants(),
              icon: Icon(Icons.refresh),
              label: Text('Load More Restaurants'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    final cardCount = provider.availableRestaurants.length;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: CardSwiper(
              key: ValueKey('swiper_$cardCount'),
              controller: _swiperController,
              cardsCount: cardCount,
              onSwipe: _onSwipe,
              numberOfCardsDisplayed: cardCount >= 2 ? 2 : 1,
              backCardOffset: Offset(0, -30),
              padding: EdgeInsets.all(0),
              scale: 0.9,
              isDisabled: _isProcessingSwipe,
              cardBuilder:
                  (context, index, horizontalThreshold, verticalThreshold) {
                    if (index >= provider.availableRestaurants.length) {
                      return SizedBox();
                    }
                    return RestaurantCard(
                      restaurant: provider.availableRestaurants[index],
                    );
                  },
            ),
          ),
        ),

        // Swipe buttons
        _buildSwipeButtons(),
      ],
    );
  }

  Widget _buildSwipeButtons() {
    return Container(
      padding: EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass button (X)
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            backgroundColor: Colors.white,
            size: 70,
            iconSize: 36,
            onPressed: _isProcessingSwipe
                ? null
                : () {
                    _swiperController?.swipe(CardSwiperDirection.left);
                  },
          ),

          SizedBox(width: 40),

          // Like button (Heart)
          _buildActionButton(
            icon: Icons.favorite,
            color: Color(0xFF4ECDC4),
            backgroundColor: Colors.white,
            size: 70,
            iconSize: 36,
            onPressed: _isProcessingSwipe
                ? null
                : () {
                    _swiperController?.swipe(CardSwiperDirection.right);
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required double size,
    required double iconSize,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
