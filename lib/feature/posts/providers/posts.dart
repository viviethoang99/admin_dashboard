import 'package:irohasu_admin/services/api/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/post_model.dart';

part 'posts.g.dart';

@riverpod
class Posts extends _$Posts {
  static const int itemsPerPage = 10;

  @override
  Future<List<PostModel>> build() async {
    final apiResult = await ref.watch(apiServiceProvider).fetchPosts();

    if (apiResult.data.isNotEmpty) {
      return apiResult.data;
    } else {
      throw Exception('Failed to fetch posts');
    }
  }
}
