import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoreader/screens/reader/document_model.dart';
import 'package:memoreader/screens/reader/line_metrics_pagination_engine.dart';

TextDocumentBlock _paragraphBlock(String text) {
  return TextDocumentBlock(
    chapterIndex: 0,
    spacingBefore: 0,
    spacingAfter: 20,
    text: text,
    nodes: [
      InlineTextNode(
        start: 0,
        end: text.length,
        style: InlineTextStyle.empty,
      ),
    ],
    baseStyle: InlineTextStyle.empty,
    textAlign: TextAlign.left,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LineMetricsPaginationEngine line-based fill', () {
    late LineMetricsPaginationEngine engine;
    const baseStyle = TextStyle(fontSize: 16, height: 1.5);
    const text = '''
Page one contains a couple of sentences that will be split into many lines. Each paragraph should behave consistently with the pagination engine.

Page two follows with the same level of verbosity so that we can verify multiple pages exist. The line metrics approach should handle this naturally without word-by-word complexity.''';

    setUpAll(() async {
      engine = await LineMetricsPaginationEngine.create(
        bookId: 'word-fill',
        blocks: [_paragraphBlock(text)],
        baseTextStyle: baseStyle,
        maxWidth: 360,
        maxHeight: 320,
        textHeightBehavior: const TextHeightBehavior(),
        textScaler: const TextScaler.linear(1.0),
        cacheManager: null,
      );
      await engine.ensureWindow(0, radius: 2);
    });

    test('produces sequential pages without gaps or overlaps', () {
      expect(engine.computedPageCount, greaterThan(1));

      final firstPage = engine.getPage(0);
      expect(firstPage, isNotNull);
      expect(firstPage!.startCharIndex, 0);
      expect(firstPage.endCharIndex >= firstPage.startCharIndex, isTrue);
      expect(firstPage.blocks, isNotEmpty);

      final secondPage = engine.getPage(1);
      expect(secondPage, isNotNull);
      expect(secondPage!.startCharIndex, equals(firstPage.endCharIndex + 1));
      expect(secondPage.blocks, isNotEmpty);
    });

    test('can find page by character index', () {
      final firstPage = engine.getPage(0);
      expect(firstPage, isNotNull);
      final midChar = (firstPage!.startCharIndex + firstPage.endCharIndex) ~/ 2;
      final foundPageIndex = engine.findPageByCharacterIndex(midChar);
      expect(foundPageIndex, equals(0));

      final secondPage = engine.getPage(1);
      if (secondPage != null) {
        final secondPageChar = secondPage.startCharIndex + 5;
        final foundSecondIndex =
            engine.findPageByCharacterIndex(secondPageChar);
        expect(foundSecondIndex, equals(1));
      }
    });

    test('pages respect maximum height constraint', () {
      for (int i = 0; i < engine.computedPageCount; i++) {
        final page = engine.getPage(i);
        expect(page, isNotNull);

        double totalHeight = 0;
        for (final block in page!.blocks) {
          totalHeight += block.spacingBefore;
          if (block is TextPageBlock) {
            totalHeight += 20;
          } else if (block is ImagePageBlock) {
            totalHeight += block.height;
          }
          totalHeight += block.spacingAfter;
        }

        expect(totalHeight, lessThanOrEqualTo(330));
      }
    });
  });
}

