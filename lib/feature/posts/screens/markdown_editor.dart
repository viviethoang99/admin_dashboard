import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../utils/code_block/plugin.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    super.key,
    this.content = '',
  });

  final String content;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  EditorState editorState = EditorState.blank();
  final controller = TextEditingController();
  final editorStyle = EditorStyle.desktop(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    cursorColor: Colors.transparent,
    cursorWidth: 0,
    selectionColor: Colors.grey.withOpacity(0.3),
    textStyleConfiguration: const TextStyleConfiguration(
      lineHeight: 1.2,
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      text: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      // code: GoogleFonts.architectsDaughter(),
      // bold: GoogleFonts.poppins(
      //   fontWeight: FontWeight.w500,
      // ),
    ),
  );

  @override
  void initState() {
    super.initState();
    controller.text = widget.content;
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Markdown Editor'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: editorStyle,
              editable: false,
              blockComponentBuilders: {
                ...standardBlockComponentBuilderMap,
                CodeBlockKeys.type: CodeBlockComponentBuilder(),
              },
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Type markdown here ...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTextChanged() {
    final document = markdownToDocument(
      controller.text,
      markdownParsers: [
        const MarkdownCodeBlockParserV2(),
      ],
    );
    setState(() {
      editorState = EditorState(document: document);
    });
  }
}

class MarkdownCodeBlockParserV2 extends CustomMarkdownParser {
  const MarkdownCodeBlockParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'pre') {
      return [];
    }

    final ec = element.children;
    if (ec == null || ec.isEmpty) {
      return [];
    }

    final code = ec.first;
    if (code is! md.Element || code.tag != 'code') {
      return [];
    }

    String? language;
    if (code.attributes.containsKey('class')) {
      final classes = code.attributes['class']!.split(' ');
      final languageClass = classes.firstWhere(
        (c) => c.startsWith('language-'),
        orElse: () => '',
      );
      language = languageClass.substring('language-'.length);
    }

    return [
      codeBlockNode(
        language: language,
        delta: Delta()..insert(code.textContent.trimRight()),
      ),
    ];
  }
}