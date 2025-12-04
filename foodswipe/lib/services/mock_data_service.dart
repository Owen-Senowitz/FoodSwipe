import '../models/user.dart';

class MockDataService {
  // Demo user accounts
  static final List<User> demoUsers = [
    User(
      id: 'user1',
      username: 'demo1',
      password: 'password',
      displayName: 'Sarah Chen',
      email: 'sarah@demo.com',
      avatarUrl: '👩‍🦰',
    ),
    User(
      id: 'user2',
      username: 'demo2',
      password: 'password',
      displayName: 'Alex Johnson',
      email: 'alex@demo.com',
      avatarUrl: '👨',
    ),
    User(
      id: 'user3',
      username: 'demo3',
      password: 'password',
      displayName: 'Maria Garcia',
      email: 'maria@demo.com',
      avatarUrl: '👩‍🦱',
    ),
    User(
      id: 'user4',
      username: 'demo4',
      password: 'password',
      displayName: 'James Kim',
      email: 'james@demo.com',
      avatarUrl: '👨‍💼',
    ),
  ];

  // Generate deterministic likes based on restaurant ID
  // This ensures every restaurant has some matches without manual configuration
  static List<String> _generateMockLikes(String restaurantId) {
    final hash = restaurantId.hashCode.abs() % 10;

    if (hash < 2) {
      return ['user2'];
    } else if (hash < 4) {
      return ['user2', 'user3'];
    } else if (hash < 6) {
      return ['user3', 'user4'];
    } else if (hash < 8) {
      return ['user2', 'user4'];
    } else {
      return ['user2', 'user3', 'user4'];
    }
  }

  // Get list of users who liked a specific restaurant
  static List<User> getUsersWhoLiked(String restaurantId) {
    final userIds = _generateMockLikes(restaurantId);
    return demoUsers.where((user) => userIds.contains(user.id)).toList();
  }

  // Validate login credentials
  static User? validateLogin(String username, String password) {
    try {
      return demoUsers.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Get count of friends who liked a restaurant (excluding current user)
  static int getMatchCount(String restaurantId, String currentUserId) {
    final userIds = _generateMockLikes(restaurantId);
    return userIds.where((id) => id != currentUserId).length;
  }
}
