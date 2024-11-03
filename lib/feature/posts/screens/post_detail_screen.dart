import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:irh_editor/irh_editor.dart';
import 'package:irohasu_admin/feature/posts/models/post_model.dart';
import '../providers/post.dart';
import 'dialog_save_blog.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: post.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('An error occurred')),
        data: (post) => _PostSuccess(post: post),
      ),
    );
  }
}

class _PostSuccess extends ConsumerStatefulWidget {
  const _PostSuccess({
    super.key,
    required this.post,
  });
  final PostModel? post;

  @override
  ConsumerState<_PostSuccess> createState() => _PostSuccessState();
}

class _PostSuccessState extends ConsumerState<_PostSuccess> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: widget.post?.title,
            decoration: InputDecoration(
              labelText: 'Tiêu đề',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 74, 137, 92),
                  width: 2.0,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 74, 137, 92),
                  width: 2.0,
                ),
              ),
              suffixIcon: Container(
                constraints: const BoxConstraints(
                  maxHeight: 48,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return DialogSaveBlog(
                              tags: widget.post?.tags ?? [],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          const Text(
            'Thể loại',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: MarkdownEditor(
                content: widget.post?.content ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  const _ChipWidget({
    super.key,
    required this.tag,
    required this.onTagRemoved,
  });

  final String tag;
  final Function(String tag) onTagRemoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
        color: Color.fromARGB(255, 74, 137, 92),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 4.0),
          InkWell(
            child: const Icon(
              Icons.cancel,
              size: 14.0,
              color: Color.fromARGB(255, 233, 233, 233),
            ),
            onTap: () => onTagRemoved(tag),
          )
        ],
      ),
    );
  }
}
