import 'package:flutter/material.dart';
import 'package:irh_editor/irh_editor.dart';

import 'dialog_save_blog.dart';


class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
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
                            return const DialogSaveBlog();
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
              child: const MarkdownEditor(
                content: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

