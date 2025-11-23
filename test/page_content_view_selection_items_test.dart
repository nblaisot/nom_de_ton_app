import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoreader/screens/reader/page_content_view.dart';

void main() {
  group('PageContentView selection menu builder', () {
    test('inserts custom action when text is selected', () {
      final baseItems = [
        ContextMenuButtonItem(onPressed: () {}, label: 'Copy'),
      ];
      bool actionCalled = false;
      bool selectionCleared = false;
      bool toolbarHidden = false;

      final items = PageContentView.buildSelectionActionItems(
        baseItems: baseItems,
        onSelectionAction: (text) {
          expect(text, 'selected text');
          actionCalled = true;
        },
        selectedText: 'selected text',
        actionLabel: 'Translate',
        clearSelection: () => selectionCleared = true,
        hideToolbar: () => toolbarHidden = true,
        isProcessingAction: false,
      );

      expect(items.length, baseItems.length + 1);
      expect(items.first.label, 'Translate');

      items.first.onPressed?.call();
      expect(actionCalled, isTrue);
      expect(selectionCleared, isTrue);
      expect(toolbarHidden, isTrue);
    });

    test('does not insert action when selection is empty or processing', () {
      final baseItems = [
        ContextMenuButtonItem(onPressed: () {}, label: 'Copy'),
      ];

      final emptySelection = PageContentView.buildSelectionActionItems(
        baseItems: baseItems,
        onSelectionAction: (text) {},
        selectedText: '   ',
        actionLabel: 'Translate',
        clearSelection: () {},
        hideToolbar: () {},
        isProcessingAction: false,
      );
      expect(emptySelection.length, baseItems.length);

      final processingSelection = PageContentView.buildSelectionActionItems(
        baseItems: baseItems,
        onSelectionAction: (text) {},
        selectedText: 'text',
        actionLabel: 'Translate',
        clearSelection: () {},
        hideToolbar: () {},
        isProcessingAction: true,
      );
      expect(processingSelection.length, baseItems.length);
    });
  });
}
