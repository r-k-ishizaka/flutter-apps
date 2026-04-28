import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.child,
    required this.actions,
    required this.onDestinationSelected,
    required this.onPostTap,
    required this.currentPath,
    this.selectedIndex = 0,
  });

  final Widget child;
  final List<Widget> actions;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPostTap;
  final String currentPath;
  final int selectedIndex;

  int get _currentIndex {
    if (currentPath.startsWith('/home/notifications')) return 1;
    return selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム'), actions: actions),
      floatingActionButton: FloatingActionButton(
        onPressed: onPostTap,
        child: const Icon(Icons.edit_note),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
        ],
      ),
      body: child,
    );
  }
}
