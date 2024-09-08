import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irohasu_admin/feature/posts/models/post_model.dart';

import '../../../services/api/api_service.dart';

class PostNotifier extends StateNotifier<PostModel> {
  PostNotifier(this.ref, PostModel state)
      : originalPost = state,
        super(state);

  final Ref ref;
  late PostModel originalPost;

  void updateTags(List<String> newTags) {
    state = state.copyWith(tags: newTags);
  }

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
  }

  bool isDifferent() {
    return state != originalPost;
  }

  void submit() {
    if (isDifferent()) {}
  }
}

final postProvider = FutureProvider.family<PostModel, String>((ref, id) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.fetchPost(id);
  return result.data;
});

final postNotifierProvider = StateNotifierProvider.family<PostNotifier, PostModel, String>((ref, id) {
  final post = ref.watch(postProvider(id)).asData?.value;
  return PostNotifier(ref, post!);
});
