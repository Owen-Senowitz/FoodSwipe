import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foodswipe/models/restaurant.dart';
import 'package:foodswipe/providers/restaurant_provider.dart';
import 'package:foodswipe/screens/favorites_screen.dart';
import 'package:foodswipe/screens/login_screen.dart';
import 'package:foodswipe/screens/restaurant_details_screen.dart';
import 'package:foodswipe/screens/settings_screen.dart';
import 'package:foodswipe/screens/swipe_screen.dart';
import 'package:foodswipe/widgets/login_scaffold.dart';
import 'package:foodswipe/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: <RouteBase>[
        ShellRoute(
          builder: (context, state, child) {
            return LoginScaffold(path: state.uri.toString(), child: child);
          },
          routes: [
            GoRoute(
              name: 'login',
              path: '/login',
              builder: (context, state) {
                return LoginScreen();
              },
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(path: state.uri.toString(), child: child);
          },
          routes: [
            GoRoute(
              name: 'home',
              path: '/home',
              builder: (context, state) => SwipeScreen(),
            ),
            GoRoute(
              name: 'settings',
              path: '/settings',
              builder: (context, state) => SettingsScreen(),
            ),
            GoRoute(
              name: 'favorites',
              path: '/favorites',
              builder: (context, state) => FavoritesScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'restaurant-details',
          path: '/restaurant/:id',
          builder: (context, state) {
            final restaurant = state.extra as Restaurant;
            return RestaurantDetailsScreen(restaurant: restaurant);
          },
        ),
      ],
    );

    return ChangeNotifierProvider(
      create: (context) => RestaurantProvider(),
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.light(
            primary: Colors.red,
            secondary: Color(0xFF4ECDC4),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
