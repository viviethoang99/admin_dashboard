library irh_editor;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:irh_editor/plugins/editor_plugins/code_block/code_block_actions.dart';
import 'package:markdown/markdown.dart' as md;

import 'plugins/editor_plugins/code_block/code_block_block_component.dart';
import 'plugins/editor_plugins/code_block/code_block_style.dart';

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
    cursorColor: Colors.red,
    cursorWidth: 2,
    selectionColor: Colors.grey.withOpacity(0.3),
    textStyleConfiguration: const TextStyleConfiguration(
      lineHeight: 1.2,
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      text: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    editorState = EditorState(
      document: customMarkdownToDocument(widget.content),
    );
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
    return AppFlowyEditor(
      editorState: editorState,
      editorStyle: editorStyle,
      editable: true,
      blockComponentBuilders: customBuilder(editorState),
    );
  }

  void _onTextChanged() {
    final document = customMarkdownToDocument(controller.text);
    setState(() {
      editorState = EditorState(document: document);
    });
  }

  Map<String, BlockComponentBuilder> customBuilder(
    EditorState editorState,
  ) {
    final configuration = BlockComponentConfiguration(
      padding: (node) {
        if (HeadingBlockKeys.type == node.type) {
          return const EdgeInsets.symmetric(vertical: 20);
        }
        return const EdgeInsets.symmetric(vertical: 5);
      },
      indentPadding: (node, textDirection) =>
          textDirection == TextDirection.ltr ? const EdgeInsets.only(left: 26.0) : const EdgeInsets.only(right: 26.0),
    );

    // customize heading block style
    return {
      ...standardBlockComponentBuilderMap,

      // heading block
      // HeadingBlockKeys.type: CustomHeadingBlockComponentBuilder(
      //   configuration: configuration,
      //   textStyleBuilder: (level) => _styleCustomizer.headingStyleBuilder(level),
      // ),

      // todo-list block
      TodoListBlockKeys.type: TodoListBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node, __) {
          final checked = node.attributes[TodoListBlockKeys.checked] as bool;
          return Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: Colors.white,
          );
        },
      ),
      // bulleted list block
      BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node) {
          return const Padding(
            padding: EdgeInsets.only(left: 10, right: 15, top: 5),
            child: Icon(
              Icons.circle,
              size: 10,
            ),
          );
        },
      ),
      // quote block
      QuoteBlockKeys.type: QuoteBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node) {
          return const EditorSvg(
            width: 20,
            height: 20,
            padding: EdgeInsets.only(right: 5.0),
            name: 'quote',
            color: Colors.pink,
          );
        },
      ),

      CodeBlockKeys.type: CodeBlockComponentBuilder(
        configuration: BlockComponentConfiguration(
          textStyle: (_) => GoogleFonts.firaCode(
            fontSize: 14,
          ),
        ),
        showLineNumbers: true,
        styleBuilder: () => CodeBlockStyle(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
        ),
        padding: const EdgeInsets.all(20).copyWith(bottom: 10),
        actions: CodeBlockActions(
          onCopy: (code) => Clipboard.setData(
            ClipboardData(text: code),
          ),
        ),
      ),
    };
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

Document customMarkdownToDocument(String markdown) {
  return markdownToDocument(
    markdown,
    markdownParsers: [
      const MarkdownCodeBlockParserV2(),
    ],
  );
}
