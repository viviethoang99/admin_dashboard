import 'package:irohasu_admin/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage.dart';

part 'api_service.g.dart';

@riverpod
ApiClient apiService(ApiServiceRef ref) {
  return ApiClient.create();
}

@riverpod
String? token(TokenRef ref) {
  final secureStorage = ref.watch(secureStorageProvider).requireValue;
  return secureStorage.get('token');
}
