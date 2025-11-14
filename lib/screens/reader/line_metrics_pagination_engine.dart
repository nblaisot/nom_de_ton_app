import 'package:flutter/material.dart';
import 'document_model.dart';

/// Line-metrics-based pagination engine that fills pages based on line heights
/// rather than word-by-word. This approach is more efficient and avoids
/// overflow issues by using Flutter's native TextPainter line metrics.
class LineMetricsPaginationEngine {
  LineMetricsPaginationEngine({
    required List<DocumentBlock> blocks,
    required TextStyle baseTextStyle,
    required double maxWidth,
    required double maxHeight,
  })  : _blocks = blocks,
        _baseTextStyle = baseTextStyle,
        _maxWidth = maxWidth,
        _originalMaxHeight = maxHeight,
        _maxHeight = maxHeight {  // Don't subtract upfront - apply during break calculation
    _buildPages();
  }
  
  // Safety margins matching cosmos_epub approach
  // cosmos_epub uses 100px when finding break point, 150px when resetting page bottom
  static const double _breakPointMargin = 100.0;  // Margin when finding break point
  static const double _pageBottomMargin = 150.0;  // Margin when resetting page bottom (matching cosmos_epub)

  final List<DocumentBlock> _blocks;
  final TextStyle _baseTextStyle;
  final double _maxWidth;
  final double _originalMaxHeight;  // Store original for page bottom calculations
  final double _maxHeight;  // Effective max height (same as original for now)

  late final List<PageContent> _pages;
  int _totalCharacters = 0;

  int get totalPages => _pages.length;
  int get totalCharacters => _totalCharacters;

  bool matches({
    required List<DocumentBlock> blocks,
    required TextStyle baseStyle,
    required double maxWidth,
    required double maxHeight,
  }) {
    return identical(_blocks, blocks) &&
        (_baseTextStyle.fontSize ?? 16) == (baseStyle.fontSize ?? 16) &&
        (_baseTextStyle.height ?? 1.6) == (baseStyle.height ?? 1.6) &&
        _baseTextStyle.fontFamily == baseStyle.fontFamily &&
        (_maxWidth - maxWidth).abs() < 0.5 &&
        (_originalMaxHeight - maxHeight).abs() < 0.5;
  }

  /// Get a page by index
  PageContent? getPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= _pages.length) {
      return null;
    }
    return _pages[pageIndex];
  }

  /// Find the page index that contains the given character index
  int findPageByCharacterIndex(int characterIndex) {
    if (_pages.isEmpty || characterIndex < 0) return 0;
    
    for (int i = 0; i < _pages.length; i++) {
      final page = _pages[i];
      if (characterIndex >= page.startCharIndex &&
          characterIndex <= page.endCharIndex) {
        return i;
      }
    }
    
    // If not found, return last page
    return _pages.length - 1;
  }

  /// Find the previous page index from current page
  int? findPreviousPage(int currentPageIndex) {
    if (currentPageIndex <= 0) return null;
    return currentPageIndex - 1;
  }

  /// Find the next page index from current page
  int? findNextPage(int currentPageIndex) {
    if (currentPageIndex >= _pages.length - 1) return null;
    return currentPageIndex + 1;
  }

  /// Find the first page for a given chapter
  int? findPageForChapter(int chapterIndex) {
    for (int i = 0; i < _pages.length; i++) {
      if (_pages[i].chapterIndex == chapterIndex) {
        return i;
      }
    }
    return null;
  }

  void _buildPages() {
    final pages = <PageContent>[];
    int globalCharacterIndex = 0;

    for (int blockIndex = 0; blockIndex < _blocks.length; blockIndex++) {
      final block = _blocks[blockIndex];

      if (block is TextDocumentBlock) {
        final textPages = _paginateTextBlock(
          block,
          globalCharacterIndex,
          pages.isEmpty,
        );
        
        for (final textPage in textPages) {
          pages.add(textPage);
          globalCharacterIndex = textPage.endCharIndex + 1;
        }
      } else if (block is ImageDocumentBlock) {
        final imagePage = _createImagePage(
          block,
          globalCharacterIndex,
          pages.isEmpty,
        );
        
        if (imagePage != null) {
          pages.add(imagePage);
          globalCharacterIndex = imagePage.endCharIndex + 1;
        }
      }
    }

    _pages = pages;
    _totalCharacters = globalCharacterIndex;
  }

  List<PageContent> _paginateTextBlock(
    TextDocumentBlock block,
    int startCharIndex,
    bool isFirstBlock,
  ) {
    final pages = <PageContent>[];
    final text = block.text;
    
    if (text.isEmpty) {
      return pages;
    }

    final textStyle = _baseTextStyle.copyWith(
      fontSize: (_baseTextStyle.fontSize ?? 16) * block.fontScale,
      fontWeight: block.fontWeight,
      fontStyle: block.fontStyle,
    );

    // Create TextPainter to get line metrics
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textAlign: block.textAlign,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: _maxWidth);

    final lines = textPainter.computeLineMetrics();
    if (lines.isEmpty) {
      return pages;
    }

    final spacingBefore = isFirstBlock ? 0.0 : block.spacingBefore;
    final spacingAfter = block.spacingAfter;

    // Match cosmos_epub approach: track cumulative height and use safety margins
    // Use effective max height with safety margin applied
    final effectiveMaxHeight = _originalMaxHeight - _pageBottomMargin;
    double currentPageHeight = spacingBefore;
    int currentPageStartCharIndex = startCharIndex;
    int currentPageStartTextIndex = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final lineHeight = line.height;
      final left = line.left;
      final top = line.baseline - line.ascent;
      
      // Calculate where this line starts in the text
      final lineStartOffset = textPainter.getPositionForOffset(
        Offset(0, top),
      ).offset;

      // Calculate cumulative height if we add this line
      final isLastLine = lineIndex == lines.length - 1;
      final effectiveSpacingAfter = isLastLine ? spacingAfter : 0.0;
      final totalHeightWithLine = currentPageHeight + lineHeight + effectiveSpacingAfter;

      // Check if adding this line would exceed effective max height
      if (totalHeightWithLine > effectiveMaxHeight && currentPageStartTextIndex < lineStartOffset) {
        // Break BEFORE the line that would overflow (matching cosmos_epub)
        // Find break point by subtracting breakPointMargin from line top
        final breakPointTop = (top - _breakPointMargin).clamp(0.0, double.infinity);
        final breakPointOffset = textPainter.getPositionForOffset(Offset(left, breakPointTop)).offset;
        
        final pageEndTextIndex = breakPointOffset > currentPageStartTextIndex
            ? breakPointOffset
            : lineStartOffset;
        
        if (pageEndTextIndex > currentPageStartTextIndex) {
          final pageText = text.substring(
            currentPageStartTextIndex,
            pageEndTextIndex,
          );

          final page = _createTextPage(
            pageText,
            textStyle,
            block.textAlign,
            block.chapterIndex,
            currentPageStartCharIndex,
            currentPageStartCharIndex + pageText.length - 1,
            currentPageStartTextIndex == 0 ? spacingBefore : 0.0,
            0.0,
          );
          pages.add(page);

          // Start new page
          currentPageStartCharIndex += pageText.length;
          currentPageStartTextIndex = pageEndTextIndex;
          currentPageHeight = 0.0;
        }
      }

      // Add line height to current page
      currentPageHeight += lineHeight;

      // If this is the last line, finalize the page
      if (isLastLine) {
        final pageText = text.substring(currentPageStartTextIndex);
        
        pages.add(_createTextPage(
          pageText,
          textStyle,
          block.textAlign,
          block.chapterIndex,
          currentPageStartCharIndex,
          currentPageStartCharIndex + pageText.length - 1,
          currentPageStartTextIndex == 0 ? spacingBefore : 0.0,
          spacingAfter,
        ));
      }
    }

    return pages;
  }

  PageContent? _createImagePage(
    ImageDocumentBlock block,
    int startCharIndex,
    bool isFirstBlock,
  ) {
    final spacingBefore = isFirstBlock ? 0.0 : block.spacingBefore;
    final spacingAfter = block.spacingAfter;

    // Calculate fitted image height
    final intrinsicWidth = block.intrinsicWidth ?? _maxWidth;
    final intrinsicHeight = block.intrinsicHeight ?? (_maxWidth * 0.6);
    
    double fittedHeight = intrinsicHeight;
    if (intrinsicWidth > 0 && intrinsicHeight > 0) {
      // Scale to fit width
      final scale = _maxWidth / intrinsicWidth;
      fittedHeight = intrinsicHeight * scale;
    }

    final availableHeight = _maxHeight - spacingBefore - spacingAfter;
    if (fittedHeight > availableHeight) {
      fittedHeight = availableHeight;
    }

    final totalHeight = spacingBefore + fittedHeight + spacingAfter;
    if (totalHeight > _maxHeight) {
      return null; // Image too large
    }

    final imageBlock = ImagePageBlock(
      bytes: block.bytes,
      height: fittedHeight,
      spacingBefore: spacingBefore,
      spacingAfter: spacingAfter,
    );

    return PageContent(
      blocks: [imageBlock],
      chapterIndex: block.chapterIndex,
      startWordIndex: startCharIndex,  // Reusing this field for character index
      endWordIndex: startCharIndex,    // Images count as one character
      startCharIndex: startCharIndex,
      endCharIndex: startCharIndex,
    );
  }

  PageContent _createTextPage(
    String text,
    TextStyle style,
    TextAlign textAlign,
    int chapterIndex,
    int startCharIndex,
    int endCharIndex,
    double spacingBefore,
    double spacingAfter,
  ) {
    final textBlock = TextPageBlock(
      text: text,
      style: style,
      textAlign: textAlign,
      spacingBefore: spacingBefore,
      spacingAfter: spacingAfter,
    );

    return PageContent(
      blocks: [textBlock],
      chapterIndex: chapterIndex,
      startWordIndex: startCharIndex, // Reusing this field for character index
      endWordIndex: endCharIndex,     // Reusing this field for character index
      startCharIndex: startCharIndex,
      endCharIndex: endCharIndex,
    );
  }
}

