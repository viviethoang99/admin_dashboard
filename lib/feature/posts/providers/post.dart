import 'package:irohasu_admin/feature/posts/models/post_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/api/api_service.dart';

part 'post.g.dart';

@riverpod
Future<PostModel> post(PostRef ref, String id) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.fetchPost(id);
  return result.data;
}
