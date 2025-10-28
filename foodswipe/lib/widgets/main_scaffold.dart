import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String path;

  const MainScaffold({required this.child, required this.path, super.key});

  int getIndexFromPath(String path) {
    if (path.startsWith('/settings')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = getIndexFromPath(path);

    String getTitleByPath(String path) {
      if (path.startsWith('/settings')) {
        return 'Settings';
      } else {
        return 'Home';
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading:
            path.contains('/details') ||
                path.contains('/addRecipe') ||
                path.contains('/groceryList')
            ? BackButton(onPressed: () => context.pop())
            : null,
        title: Row(
          children: [
            Text(getTitleByPath(path)),
            Spacer(),
            IconButton(
              onPressed: () {
                context.pushNamed('groceryList');
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ],
        ),
      ),
      body: child,
      floatingActionButton: path == '/home'
          ? FloatingActionButton(
              onPressed: () {
                context.pushNamed('addRecipe');
              },
              child: Icon(Icons.add, color: Colors.black87),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              context.goNamed('settings');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
