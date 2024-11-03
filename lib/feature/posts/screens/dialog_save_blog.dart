import 'package:flutter/material.dart';

import '../../widget/dropdown_textfield.dart';

class DialogSaveBlog extends StatefulWidget {
  const DialogSaveBlog({
    super.key,
    this.tags = const [],
  });

  final List<String> tags;

  @override
  State<DialogSaveBlog> createState() => _DialogSaveBlogState();
}

class _DialogSaveBlogState extends State<DialogSaveBlog> {
  bool isPublic = false;
  bool isPinPost = false;
  bool isShowAddTag = false;
  List<String> tags = [];

  @override
  void initState() {
    for (var tag in widget.tags) {
      if (tag.isNotEmpty) tags.add(tag);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lưu bài viết'),
      content: Builder(builder: (context) {
        return SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              _ContentWidget(
                label: 'Thể loại',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (var tag in tags)
                      Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            tags.remove(tag);
                          });
                        },
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isShowAddTag
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: CourseDropdownTextField(
                                onSubmitted: (value) {
                                  setState(() {
                                    tags.add(value);
                                    isShowAddTag = false;
                                  });
                                },
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  isShowAddTag = true;
                                });
                              },
                              child: const Chip(
                                label: Icon(
                                  Icons.add,
                                  size: 19,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ContentWidget(
                label: 'Ghim bai viet',
                child: Switch(
                  value: isPinPost,
                  onChanged: (value) {
                    setState(() {
                      isPinPost = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _ContentWidget(
                label: 'Trạng thái',
                child: Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value ?? false;
                        });
                      },
                    ),
                    const Text('Công khai'),
                    const SizedBox(width: 20),
                    Radio(
                      value: false,
                      groupValue: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value ?? false;
                        });
                      },
                    ),
                    const Text('Riêng tư'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _ContentWidget extends StatelessWidget {
  const _ContentWidget({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 150, child: Text(label)),
        const SizedBox(width: 20),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ],
    );
  }
}
