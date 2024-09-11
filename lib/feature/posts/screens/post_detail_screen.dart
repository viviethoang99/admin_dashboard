import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:irh_editor/irh_editor.dart';
import 'package:irohasu_admin/feature/posts/models/post_model.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../providers/post.dart';

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
  const _PostSuccess({super.key, required this.post});
  final PostModel? post;

  @override
  ConsumerState<_PostSuccess> createState() => _PostSuccessState();
}

class _PostSuccessState extends ConsumerState<_PostSuccess> {
  late StringTagController _stringTagController;
  late double _distanceToField;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    _stringTagController = StringTagController();
    _stringTagController.addListener(() {
      ref.read(postNotifierProvider(widget.post!.id!).notifier).updateTags(_stringTagController.getTags ?? []);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stringTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Tiêu đề',
              labelStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            initialValue: widget.post?.title,
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          const Text(
            'Thể loại',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFieldTags<String>(
                  textfieldTagsController: _stringTagController,
                  initialTags: widget.post?.tags,
                  textSeparators: const [' ', ','],
                  letterCase: LetterCase.normal,
                  validator: (String tag) {
                    if (_stringTagController.getTags!.contains(tag)) {
                      return 'You\'ve already entered that';
                    }

                    return null;
                  },
                  inputFieldBuilder: (context, inputFieldValues) {
                    return TextField(
                      onTap: () {
                        _stringTagController.getFocusNode?.requestFocus();
                      },
                      controller: inputFieldValues.textEditingController,
                      focusNode: inputFieldValues.focusNode,
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 74, 137, 92),
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 74, 137, 92),
                            width: 3.0,
                          ),
                        ),
                        helperText: 'Enter language...',
                        helperStyle: const TextStyle(
                          color: Color.fromARGB(255, 74, 137, 92),
                        ),
                        hintText: inputFieldValues.tags.isNotEmpty ? '' : "Enter tag...",
                        errorText: inputFieldValues.error,
                        prefixIconConstraints: BoxConstraints(maxWidth: _distanceToField * 0.8),
                        prefixIcon: inputFieldValues.tags.isNotEmpty
                            ? SingleChildScrollView(
                                controller: inputFieldValues.tagScrollController,
                                scrollDirection: Axis.vertical,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    left: 8,
                                  ),
                                  child: Wrap(
                                      runSpacing: 4.0,
                                      spacing: 4.0,
                                      children: inputFieldValues.tags.map((String tag) {
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
                                              InkWell(
                                                child: Text(
                                                  tag,
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                                onTap: () {
                                                  //print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  inputFieldValues.onTagRemoved(tag);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                ),
                              )
                            : null,
                      ),
                      onChanged: inputFieldValues.onTagChanged,
                      onSubmitted: inputFieldValues.onTagSubmitted,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.post?.id != null) {
                    ref.read(postNotifierProvider(widget.post!.id!).notifier).submit();
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
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
