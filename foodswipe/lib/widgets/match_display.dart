import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class MatchDisplay extends StatelessWidget {
  final Restaurant restaurant;
  final String currentUserId;

  const MatchDisplay({
    required this.restaurant,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final matches = MockDataService.getUsersWhoLiked(restaurant.id)
        .where((user) => user.id != currentUserId)
        .toList();

    if (matches.isEmpty) {
      return SizedBox.shrink(); // Don't show if no matches
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${matches.length} ${matches.length == 1 ? 'friend' : 'friends'} also liked this!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: matches.map((user) => _buildUserChip(user)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserChip(User user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.avatarUrl,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 8),
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
}
