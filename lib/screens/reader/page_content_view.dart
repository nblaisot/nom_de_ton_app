import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../screens/reader/document_model.dart';

class PageContentView extends StatefulWidget {
  const PageContentView({
    super.key,
    required this.content,
    required this.maxWidth,
    required this.maxHeight,
    required this.textHeightBehavior,
    required this.textScaler,
    required this.actionLabel,
    required this.onSelectionAction,
    required this.onSelectionChanged,
    required this.isProcessingAction,
  });

  final PageContent content;
  final double maxWidth;
  final double maxHeight;
  final TextHeightBehavior textHeightBehavior;
  final TextScaler textScaler;
  final String actionLabel;
  final ValueChanged<String>? onSelectionAction;
  final void Function(bool hasSelection, VoidCallback clearSelection)?
      onSelectionChanged;
  final bool isProcessingAction;

  @visibleForTesting
  static List<ContextMenuButtonItem> buildSelectionActionItems({
    required List<ContextMenuButtonItem> baseItems,
    required ValueChanged<String>? onSelectionAction,
    required String selectedText,
    required String actionLabel,
    required VoidCallback clearSelection,
    required VoidCallback hideToolbar,
    required bool isProcessingAction,
  }) {
    final items = List<ContextMenuButtonItem>.from(baseItems);
    final trimmedText = selectedText.trim();
    if (trimmedText.isNotEmpty &&
        onSelectionAction != null &&
        !isProcessingAction) {
      items.insert(
        0,
        ContextMenuButtonItem(
          onPressed: () {
            hideToolbar();
            onSelectionAction(trimmedText);
            clearSelection();
          },
          label: actionLabel,
        ),
      );
    }
    return items;
  }

  @override
  State<PageContentView> createState() => _PageContentViewState();
}

class _PageContentViewState extends State<PageContentView> {
  String _selectedText = '';
  int _selectionGeneration = 0;

  void _clearSelection() {
    setState(() {
      _selectedText = '';
      _selectionGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (final block in widget.content.blocks) {
      if (block.spacingBefore > 0) {
        children.add(SizedBox(height: block.spacingBefore));
      }

      if (block is TextPageBlock) {
        children.add(
          SelectableText.rich(
            _buildRichTextSpan(block),
            textAlign: block.textAlign,
            textHeightBehavior: widget.textHeightBehavior,
            textScaler: widget.textScaler,
            contextMenuBuilder: (context, editableTextState) {
              final items = PageContentView.buildSelectionActionItems(
                baseItems: editableTextState.contextMenuButtonItems.toList(),
                onSelectionAction: widget.onSelectionAction,
                selectedText: _selectedText,
                actionLabel: widget.actionLabel,
                clearSelection: _clearSelection,
                hideToolbar: editableTextState.hideToolbar,
                isProcessingAction: widget.isProcessingAction,
              );
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: items,
              );
            },
            onSelectionChanged: (selection, cause) {
              final base = selection.baseOffset;
              final extent = selection.extentOffset;
              final valid = base >= 0 && extent >= 0;
              final hasSelection = valid &&
                  (base != extent ||
                      cause == SelectionChangedCause.longPress ||
                      cause == SelectionChangedCause.drag);
              final lower = base < extent ? base : extent;
              final upper = base < extent ? extent : base;
              final selected = hasSelection && lower != upper
                  ? block.text.substring(
                      lower.clamp(0, block.text.length),
                      upper.clamp(0, block.text.length),
                    )
                  : '';
              setState(() {
                _selectedText = selected;
              });
              widget.onSelectionChanged?.call(hasSelection, _clearSelection);
            },
          ),
        );
      } else if (block is ImagePageBlock) {
        children.add(
          SizedBox(
            height: block.height,
            width: widget.maxWidth,
            child: material.Image.memory(
              block.bytes,
              fit: BoxFit.contain,
            ),
          ),
        );
      }

      if (block.spacingAfter > 0) {
        children.add(SizedBox(height: block.spacingAfter));
      }
    }

    return SizedBox(
      key: ValueKey(_selectionGeneration),
      width: widget.maxWidth,
      height: widget.maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }

  TextSpan _buildRichTextSpan(TextPageBlock block) {
    final fragments = block.fragments;
    if (fragments.isEmpty) {
      return TextSpan(
        text: block.text,
        style: block.baseStyle,
      );
    }
    final children = <InlineSpan>[];
    for (final fragment in fragments) {
      if (fragment.type == InlineFragmentType.text &&
          fragment.text != null &&
          fragment.text!.isNotEmpty) {
        children.add(
          TextSpan(
            text: fragment.text,
            style: fragment.style ?? block.baseStyle,
          ),
        );
      } else if (fragment.type == InlineFragmentType.image &&
          fragment.image != null) {
        final image = fragment.image!;
        children.add(
          WidgetSpan(
            alignment: image.alignment,
            baseline: image.baseline,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxHeight * 0.6,
              ),
              child: material.Image.memory(
                image.bytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      }
    }
    return TextSpan(
      style: block.baseStyle.copyWith(height: block.lineHeight),
      children: children,
    );
  }
}
