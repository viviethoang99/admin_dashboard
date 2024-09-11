import 'dart:async';

import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:provider/provider.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import '../../../shared/spacing.dart';
import 'code_block_actions.dart';
import 'code_block_localization.dart';
import 'code_block_style.dart';

class CodeBlockKeys {
  const CodeBlockKeys._();

  static const String type = 'code';

  /// The content of a code block.
  ///
  /// The value is a String.
  static const String delta = 'delta';

  /// The language of a code block.
  ///
  /// The value is a String.
  static const String language = 'language';
}

Node codeBlockNode({
  Delta? delta,
  String? language,
}) {
  final attributes = {
    CodeBlockKeys.delta: (delta ?? Delta()).toJson(),
    CodeBlockKeys.language: language,
  };
  return Node(
    type: CodeBlockKeys.type,
    attributes: attributes,
  );
}

// Code block menu item for selection
SelectionMenuItem codeBlockItem(
  String name, [
  IconData icon = Icons.abc,
  List<String> keywords = const ['code', 'codeblock'],
  String? language,
]) =>
    SelectionMenuItem.node(
      getName: () => name,
      iconData: icon,
      keywords: keywords,
      nodeBuilder: (_, __) => codeBlockNode(language: language),
      replace: (_, node) => node.delta?.isEmpty ?? false,
    );

const _interceptorKey = 'code-block-interceptor';

/// Used to provide a custom Language picker widget for the [CodeBlockComponentWidget].
///
typedef CodeBlockLanguagePickerBuilder = Widget Function(
  EditorState editorState,
  List<String> supportedLanguages,
  void Function(String language) onLanguageSelected, {
  String? selectedLanguage,

  /// Used to manage the visibility of the language picker, to ensure
  /// it is visible while the user is currently interacting with it.
  VoidCallback? onMenuOpen,
  VoidCallback? onMenuClose,
});

/// Used to provide a custom copy button for the [CodeBlockComponentWidget].
///
typedef CodeBlockCopyBuilder = Widget Function(EditorState, Node);

class CodeBlockComponentBuilder extends BlockComponentBuilder {
  CodeBlockComponentBuilder({
    super.configuration,
    this.padding = const EdgeInsets.only(
      top: 20,
      left: 20,
      right: 20,
      bottom: 34,
    ),
    this.styleBuilder,
    this.actions = const CodeBlockActions(),
    this.actionWrapperBuilder,
    this.languagePickerBuilder,
    this.copyButtonBuilder,
    this.localizations = const CodeBlockLocalizations(),
    this.showLineNumbers = true,
  });

  final EdgeInsets padding;
  final CodeBlockStyle Function()? styleBuilder;
  final CodeBlockActions actions;
  final Widget Function(
    Node node,
    EditorState editorState,
    Widget child,
  )? actionWrapperBuilder;
  final CodeBlockLanguagePickerBuilder? languagePickerBuilder;
  final CodeBlockCopyBuilder? copyButtonBuilder;
  final CodeBlockLocalizations localizations;
  final bool showLineNumbers;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return CodeBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      padding: padding,
      showActions: showActions(node),
      actionBuilder: (_, state) => actionBuilder(blockComponentContext, state),
      actionWrapperBuilder: actionWrapperBuilder,
      style: styleBuilder?.call(),
      languagePickerBuilder: languagePickerBuilder,
      actions: actions,
      copyButtonBuilder: copyButtonBuilder,
      localizations: localizations,
      showLineNumbers: showLineNumbers,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

/// A widget representing a code block component.
///
/// It is highly recommended to use a monospace font for the code block,
/// as otherwise the alignment of line numbers and lines won't match up.
///
class CodeBlockComponentWidget extends BlockComponentStatefulWidget {
  const CodeBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.padding = const EdgeInsets.all(20),
    this.style,
    this.actions = const CodeBlockActions(),
    this.actionWrapperBuilder,
    this.languagePickerBuilder,
    this.copyButtonBuilder,
    this.localizations = const CodeBlockLocalizations(),
    this.showLineNumbers = true,
  });

  final EdgeInsets padding;

  /// The style of the code block.
  ///
  /// If null, theme defaults will be used.
  ///
  final CodeBlockStyle? style;

  /// The actions available for the code block.
  ///
  final CodeBlockActions actions;

  /// The builder for the action widgets.
  ///
  /// Used to override the default action wrapper,
  /// especially useful for mobile adaptation.
  ///
  /// _Note: This renders the [actionBuilder] obsolete!_
  ///
  final Widget Function(
    Node node,
    EditorState editorState,
    Widget child,
  )? actionWrapperBuilder;

  /// Provide a custom Widget for the language picker.
  ///
  /// It is highly recommended to replace the default language picker that
  /// consists of a [DropdownMenu], with a custom picker that fits the
  /// design of your app.
  ///
  final CodeBlockLanguagePickerBuilder? languagePickerBuilder;

  /// Provide a custom Widget for the copy button.
  ///
  /// It is highly recommended to replace the default copy button that
  /// consists of a simple [IconButton], with a custom button that fits the
  /// design of your app.
  ///
  final CodeBlockCopyBuilder? copyButtonBuilder;

  final CodeBlockLocalizations localizations;

  final bool showLineNumbers;

  @override
  State<CodeBlockComponentWidget> createState() => _CodeBlockComponentWidgetState();
}

class _CodeBlockComponentWidgetState extends State<CodeBlockComponentWidget>
    with SelectableMixin, DefaultSelectableMixin, BlockComponentConfigurable, BlockComponentTextDirectionMixin {
  // The key used to forward focus to the richtext child
  @override
  final forwardKey = GlobalKey(debugLabel: 'code_flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(debugLabel: CodeBlockKeys.type);

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => node.key;

  @override
  Node get node => widget.node;

  @override
  late EditorState editorState;

  final scrollController = ScrollController();

  // We use this to calculate the position of the cursor in the code block
  // for automatic scrolling.
  final codeBlockKey = GlobalKey();

  String? get language => node.attributes[CodeBlockKeys.language] as String?;
  String? autoDetectLanguage;

  bool isSelected = false;
  bool isHovering = false;
  bool canPanStart = true;

  late final interceptor = SelectionGestureInterceptor(
    key: _interceptorKey,
    canTap: (_) => canPanStart && !isSelected,
    canPanStart: (_) => canPanStart && !isSelected,
  );

  late final StreamSubscription<(TransactionTime, Transaction)> transactionSubscription;

  @override
  void initState() {
    super.initState();
    editorState = context.read<EditorState>();
    editorState.selectionService.registerGestureInterceptor(interceptor);
    editorState.selectionNotifier.addListener(calculateScrollPosition);
    transactionSubscription = editorState.transactionStream.listen((event) {
      if (event.$2.operations.any((op) => op.path.equals(node.path))) {
        calculateScrollPosition();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    editorState.selectionService.currentSelection.removeListener(calculateScrollPosition);
    editorState.selectionService.unregisterGestureInterceptor(_interceptorKey);

    editorState = context.read<EditorState>();
  }

  @override
  void dispose() {
    scrollController.dispose();
    editorState.selectionService.currentSelection.removeListener(calculateScrollPosition);
    editorState.selectionService.unregisterGestureInterceptor(_interceptorKey);
    transactionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: widget.style?.backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          textDirection: textDirection,
          children: [
            _buildAppbar(),
            _buildCodeBlock(context, textDirection),
          ],
        ),
      ),
    );

    child = Padding(key: blockComponentKey, padding: padding, child: child);

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [BlockSelectionType.block],
      child: child,
    );

    if (widget.actionWrapperBuilder != null) {
      child = widget.actionWrapperBuilder!(node, editorState, child);
    } else if (PlatformExtension.isDesktopOrWeb) {
      if (widget.showActions && widget.actionBuilder != null) {
        child = BlockComponentActionWrapper(
          node: widget.node,
          actionBuilder: widget.actionBuilder!,
          child: child,
        );
      }
    }

    return child;
  }

  Widget _buildAppbar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF292b2f),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const HSpace(16),
          const _DotsWidget(),
          const HSpace(4),
          // IrohaText.medium(
          //   language?.capitalize() ?? '',
          //   fontSize: 16,
          // ),
          const Spacer(),
          if (widget.actions.onCopy != null && widget.copyButtonBuilder == null) ...[
            _CopyButton(
              node: node,
              onCopy: widget.actions.onCopy!,
              localizations: widget.localizations,
              foregroundColor: widget.style?.foregroundColor,
            ),
          ] else if (widget.copyButtonBuilder != null) ...[
            widget.copyButtonBuilder!(editorState, node),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeBlock(BuildContext context, TextDirection textDirection) {
    final delta = node.delta ?? Delta();
    final content = delta.toPlainText();

    final linesOfCode = delta.toPlainText().split('\n').length;

    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLineNumbers) ...[
            _LinesOfCodeNumbers(
              linesOfCode: linesOfCode,
              textStyle: textStyle.copyWith(
                color:
                    widget.style?.foregroundColor ?? Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(155),
              ),
            ),
          ],
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  key: codeBlockKey,
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: FutureBuilder(
                    future: isLightMode ? HighlighterTheme.loadLightTheme() : HighlighterTheme.loadDarkTheme(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      Highlighter highlighter = Highlighter(
                        language: 'dart',
                        theme: snapshot.data!,
                      );

                      final textSpanCode = highlighter.highlight(content).copyWith(style: textStyle);

                      return AppFlowyRichText(
                        key: forwardKey,
                        delegate: this,
                        node: widget.node,
                        editorState: editorState,
                        placeholderText: placeholderText,
                        lineHeight: 1.5,
                        textSpanDecorator: (_) => textSpanCode,
                        placeholderTextSpanDecorator: (textSpan) => textSpan,
                        textDirection: textDirection,
                        cursorColor: editorState.editorStyle.cursorColor,
                        selectionColor: editorState.editorStyle.selectionColor,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calculateScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selection = editorState.selection;
      if (!mounted || selection == null || !selection.isCollapsed) {
        return;
      }

      final nodes = editorState.getNodesInSelection(selection);
      if (nodes.isEmpty || nodes.length > 1) {
        return;
      }

      final selectedNode = nodes.first;
      if (selectedNode.path.equals(widget.node.path)) {
        final renderBox = codeBlockKey.currentContext?.findRenderObject() as RenderBox?;
        final rects = editorState.selectionRects();
        if (renderBox == null || rects.isEmpty) {
          return;
        }

        final codeBlockOffset = renderBox.localToGlobal(Offset.zero);
        final codeBlockSize = renderBox.size;

        final cursorRect = rects.first;
        final cursorRelativeOffset = cursorRect.center - codeBlockOffset;

        // If the relative position of the cursor is less than 1, and the scrollController
        // is not at offset 0, then we need to scroll to the left to make cursor visible.
        if (cursorRelativeOffset.dx < 1 && scrollController.offset > 0) {
          scrollController.jumpTo(
            scrollController.offset + cursorRelativeOffset.dx - 1,
          );

          // If the relative position of the cursor is greater than the width of the code block,
          // then we need to scroll to the right to make cursor visible.
        } else if (cursorRelativeOffset.dx > codeBlockSize.width - 1) {
          scrollController.jumpTo(
            scrollController.offset + cursorRelativeOffset.dx - codeBlockSize.width + 1,
          );
        }
      }
    });
  }
}

class _LinesOfCodeNumbers extends StatelessWidget {
  const _LinesOfCodeNumbers({
    required this.linesOfCode,
    required this.textStyle,
  });

  final int linesOfCode;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 1; i <= linesOfCode; i++) Text(i.toString(), style: textStyle),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({
    required this.node,
    required this.onCopy,
    required this.localizations,
    this.foregroundColor,
  });

  final Node node;
  final void Function(String) onCopy;
  final CodeBlockLocalizations localizations;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Tooltip(
        message: localizations.copyTooltip,
        child: IconButton(
          onPressed: () {
            final delta = node.delta?.toPlainText();
            if (delta != null) {
              onCopy(delta);
            }
          },
          hoverColor: Theme.of(context).colorScheme.secondaryContainer,
          icon: Icon(
            Icons.copy,
            color: foregroundColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

const _listColorDots = [Color(0xFFCF625D), Color(0xFFfdbc40), Color(0xFF67e559)];

class _DotsWidget extends StatelessWidget {
  const _DotsWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _listColorDots.length,
        (index) => Container(
          width: 12.0,
          height: 12.0,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _listColorDots[index],
          ),
        ),
      ),
    );
  }
}
