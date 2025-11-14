/// Models shared by the reader pagination system.
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Base class representing a block extracted from the EPUB document.
abstract class DocumentBlock {
  const DocumentBlock({
    required this.chapterIndex,
    required this.spacingBefore,
    required this.spacingAfter,
  });

  final int chapterIndex;
  final double spacingBefore;
  final double spacingAfter;
}

class TextDocumentBlock extends DocumentBlock {
  const TextDocumentBlock({
    required super.chapterIndex,
    required super.spacingBefore,
    required super.spacingAfter,
    required this.text,
    required this.fontScale,
    required this.fontWeight,
    required this.fontStyle,
    required this.textAlign,
  });

  final String text;
  final double fontScale;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextAlign textAlign;
}

class ImageDocumentBlock extends DocumentBlock {
  const ImageDocumentBlock({
    required super.chapterIndex,
    required super.spacingBefore,
    required super.spacingAfter,
    required this.bytes,
    required this.intrinsicWidth,
    required this.intrinsicHeight,
  });

  final Uint8List bytes;
  final double? intrinsicWidth;
  final double? intrinsicHeight;
}

/// Content calculated for a single rendered page.
class PageContent {
  const PageContent({
    required this.blocks,
    required this.chapterIndex,
    required this.startWordIndex,
    required this.endWordIndex,
    int? startCharIndex,
    int? endCharIndex,
  })  : startCharIndex = startCharIndex ?? startWordIndex,
        endCharIndex = endCharIndex ?? endWordIndex;

  final List<PageBlock> blocks;
  final int chapterIndex;
  final int startWordIndex;
  final int endWordIndex;
  // Character-based indices for more accurate progress tracking
  final int startCharIndex;
  final int endCharIndex;
}

abstract class PageBlock {
  const PageBlock({
    required this.spacingBefore,
    required this.spacingAfter,
  });

  final double spacingBefore;
  final double spacingAfter;
}

class TextPageBlock extends PageBlock {
  const TextPageBlock({
    required this.text,
    required this.style,
    required this.textAlign,
    required super.spacingBefore,
    required super.spacingAfter,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
}

class ImagePageBlock extends PageBlock {
  const ImagePageBlock({
    required this.bytes,
    required this.height,
    required super.spacingBefore,
    required super.spacingAfter,
  });

  final Uint8List bytes;
  final double height;
}
