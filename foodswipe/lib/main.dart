import 'package:flutter/material.dart';
import 'package:foodswipe/screens/home_screen.dart';
import 'package:foodswipe/screens/login_screen.dart';
import 'package:foodswipe/screens/settings_screen.dart';
import 'package:foodswipe/widgets/login_scaffold.dart';
import 'package:foodswipe/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';

void main() {
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
              builder: (context, state) {
                return HomeScreen();
              },
            ),
            GoRoute(
              name: 'settings',
              path: '/settings',
              builder: (context, state) {
                return SettingsScreen();
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }
}
