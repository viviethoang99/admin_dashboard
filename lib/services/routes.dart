import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:irohasu_admin/feature/login/screen/login_page.dart';
import 'package:irohasu_admin/feature/posts/screens/post_detail_screen.dart';
import 'package:irohasu_admin/feature/tags/screen/list_tag_screen.dart';
import 'package:irohasu_admin/services/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../feature/posts/screens/list_post_tab.dart';
import '../feature/posts/screens/new_post_screen.dart';
import '../feature/widget/scaffold_with_navigation.dart';

part 'routes.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authStateNotifier = ValueNotifier(AuthState.unknown);

  ref
    ..onDispose(authStateNotifier.dispose)
    ..listen(currentAuthStateProvider, (_, state) => authStateNotifier.value = state);

  final navigationItems = [
    NavigationItem(
      path: '/posts',
      body: (_) => const ListPostTab(),
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
      label: 'Todos',
      routes: [
        GoRoute(
          path: 'add',
          builder: (_, __) => Container(),
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id'] ?? '';
            return PostDetailScreen(id);
          },
          routes: [
            GoRoute(
              path: 'update',
              builder: (_, state) {
                final id = state.pathParameters['id'] ?? '';
                return PostDetailScreen(id);
              },
            ),
          ],
        ),
      ],
    ),
    NavigationItem(
      path: '/create',
      body: (_) => const NewPostScreen(),
      icon: Icons.co_present_outlined,
      label: 'Create',
    ),
    NavigationItem(
      path: '/profile',
      body: (_) => const SizedBox.shrink(),
      icon: Icons.co_present_outlined,
      label: 'Profile',
    ),
    NavigationItem(
      path: '/tags',
      body: (_) => const ListTagTab(),
      icon: Icons.abc_rounded,
      label: 'Thể loại',
    ),
  ];

  final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => child,
        routes: [
          for (final (index, item) in navigationItems.indexed)
            GoRoute(
              path: item.path,
              pageBuilder: (context, _) => NoTransitionPage(
                child: ScaffoldWithNavigation(
                  selectedIndex: index,
                  navigationItems: navigationItems,
                  child: item.body(context),
                ),
              ),
              routes: item.routes,
            ),
        ],
      ),
    ],
    refreshListenable: authStateNotifier,
    redirect: (_, state) {
      final authState = ref.read(currentAuthStateProvider);

      if (!authState.allowedPaths.contains(state.fullPath)) {
        return authState.redirectPath;
      }

      return null;
    },
  );

  ref.onDispose(router.dispose);

  return router;
}
