import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.child,
    required this.actions,
    required this.onTimelineTap,
    this.selectedIndex = 0,
  });

  final Widget child;
  final List<Widget> actions;
  final VoidCallback onTimelineTap;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム'), actions: actions),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              onTimelineTap();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed),
            label: 'Timeline',
          ),
        ],
      ),
      body: child,
    );
  }
}
