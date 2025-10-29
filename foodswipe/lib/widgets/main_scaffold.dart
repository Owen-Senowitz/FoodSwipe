import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String path;

  const MainScaffold({required this.child, required this.path, super.key});

  int getIndexFromPath(String path) {
    if (path.startsWith('/favorites')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = getIndexFromPath(path);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: path.startsWith('/settings')
          ? null
          : AppBar(
              backgroundColor: Colors.red,
              elevation: 0,
              title: Text(
                'FoodSwipe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  context.goNamed("settings");
                },
              ),
            ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              context.goNamed('favorites');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
