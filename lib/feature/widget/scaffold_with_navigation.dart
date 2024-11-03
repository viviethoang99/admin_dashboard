import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.navigationItems,
  });

  final Widget child;
  final int selectedIndex;
  final List<NavigationItem> navigationItems;

  @override
  Widget build(BuildContext context) {
    void onDestinationSelected(int index) => context.go(navigationItems[index].path);

    // Use navigation rail instead of navigation bar when the screen width is
    // larger than 600dp.
    if (MediaQuery.sizeOf(context).width > 600) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              elevation: 10,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final item in navigationItems)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: item.selectedIcon != null ? Icon(item.selectedIcon) : null,
                    label: Text(item.label),
                  )
              ],
              extended: true,
            ),
            Expanded(
                child: Column(
              children: [
                const Text('Irohasu Admin'),
                const Divider(),
                Expanded(child: child),
              ],
            )),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final item in navigationItems)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: item.selectedIcon != null ? Icon(item.selectedIcon) : null,
              label: item.label,
            )
        ],
      ),
    );
  }
}

/// An item that represents a navigation destination in a navigation bar/rail.
class NavigationItem {
  /// Path in the router.
  final String path;

  /// Widget to show when navigating to this [path].
  final WidgetBuilder body;

  /// Icon in the navigation bar.
  final IconData icon;

  /// Icon in the navigation bar when selected.
  final IconData? selectedIcon;

  /// Label in the navigation bar.
  final String label;

  /// The subroutes of the route from this [path].
  final List<RouteBase> routes;

  NavigationItem({
    required this.path,
    required this.body,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.routes = const [],
  });
}
