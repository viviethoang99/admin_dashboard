import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:irohasu_admin/feature/posts/models/post_model.dart';

import '../providers/post.dart';
import 'markdown_editor.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: post.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('An error occurred')),
        data: (post) => _PostSuccess(post: post),
      ),
    );
  }
}

class _PostSuccess extends StatelessWidget {
  const _PostSuccess({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Title'),
          initialValue: post.title,
        ),
        const Expanded(child: MarkdownEditor())
      ],
    );
  }
}
