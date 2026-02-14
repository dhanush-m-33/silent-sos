import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';

/// Persistent bottom navigation bar shell.
/// Wraps all main app screens (Home, Evidence, Contacts, Profile).
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  // Map each tab index to its route
  static const _routes = [
    AppRoutes.home,
    AppRoutes.evidence,
    AppRoutes.contacts,
    AppRoutes.profile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index != currentIndex) {
              context.go(_routes[index]);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: AppStrings.navEvidence,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              activeIcon: Icon(Icons.contacts),
              label: AppStrings.navContacts,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
