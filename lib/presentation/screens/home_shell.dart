import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final index = switch (location) {
      final l when l.startsWith('/management') => 1,
      final l when l.startsWith('/settings') => 2,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBar(
            height: 70,
            selectedIndex: index,
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/dashboard');
                case 1:
                  context.go('/management');
                case 2:
                  context.go('/settings');
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                label: 'Management',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
