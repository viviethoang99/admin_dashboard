import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:irohasu_admin/feature/login/screen/login_page.dart';
import 'package:irohasu_admin/feature/posts/screens/post_detail_screen.dart';
import 'package:irohasu_admin/services/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../feature/posts/screens/list_post_tab.dart';

part 'routes.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authStateNotifier = ValueNotifier(AuthState.unknown);

  ref
    ..onDispose(authStateNotifier.dispose)
    ..listen(currentAuthStateProvider, (_, state) => authStateNotifier.value = state);

  final navigationItems = [
    GoRoute(
      path: '/posts',
      builder: (_, __) => const ListPostTab(),
      routes: [
        GoRoute(
          path: 'create',
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
  ];

  final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      ...navigationItems,
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
