import 'package:irohasu_admin/services/storage/secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../feature/login/models/login.dart';
import 'api/api_service.dart';

part 'auth_state.g.dart';

@riverpod
class CurrentAuthState extends _$CurrentAuthState {
  @override
  AuthState build() {
    final secureStorage = ref.watch(secureStorageProvider).requireValue;
    final token = secureStorage.get('token');
    return token == null ? AuthState.unauthenticated : AuthState.authenticated;
  }

  Future<void> login(Login data) async {
    final secureStorage = ref.read(secureStorageProvider).requireValue;
    final result = await ref.read(apiServiceProvider).login(data);

    secureStorage.set('token', result.data.token);
    ref
      ..invalidateSelf()
      ..invalidate(apiServiceProvider);
  }

  void logout() {
    final secureStorage = ref.read(secureStorageProvider).requireValue;
    secureStorage.remove('token');
    ref
      ..invalidateSelf()
      ..invalidate(apiServiceProvider);
  }
}

/// The possible authentication states of the app.
enum AuthState {
  unknown(
    redirectPath: '/',
    allowedPaths: [
      '/',
    ],
  ),
  unauthenticated(
    redirectPath: '/login',
    allowedPaths: [
      '/login',
      '/settings',
    ],
  ),
  authenticated(
    redirectPath: '/posts',
    allowedPaths: [
      '/posts',
      '/posts/:id',
      '/tags',
      '/create',
      '/profile',
      '/settings',
    ],
  ),
  ;

  const AuthState({
    required this.redirectPath,
    required this.allowedPaths,
  });

  /// The target path to redirect when the current route is not allowed in this
  /// auth state.
  final String redirectPath;

  /// List of paths allowed when the app is in this auth state.
  final List<String> allowedPaths;
}
