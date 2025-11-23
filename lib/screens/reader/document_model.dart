// Models shared by the reader pagination system.
import 'dart:typed_data';

import 'package:flutter/material.dart';

class InlineTextStyle {
  const InlineTextStyle({
    this.fontScale,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.fontFamily,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.decoration,
  });

  final double? fontScale;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Color? color;
  final String? fontFamily;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final TextDecoration? decoration;

  static const InlineTextStyle empty = InlineTextStyle();

  InlineTextStyle merge(InlineTextStyle other) {
    return InlineTextStyle(
      fontScale: other.fontScale ?? fontScale,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      color: other.color ?? color,
      fontFamily: other.fontFamily ?? fontFamily,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      wordSpacing: other.wordSpacing ?? wordSpacing,
      height: other.height ?? height,
      decoration: other.decoration ?? decoration,
    );
  }

  bool get isPlain =>
      fontScale == null &&
      fontWeight == null &&
      fontStyle == null &&
      color == null &&
      fontFamily == null &&
      letterSpacing == null &&
      wordSpacing == null &&
      height == null &&
      decoration == null;

  TextStyle resolve(TextStyle base) {
    var result = base;
    if (fontScale != null && base.fontSize != null) {
      result = result.copyWith(fontSize: base.fontSize! * fontScale!);
    }
    if (fontWeight != null) {
      result = result.copyWith(fontWeight: fontWeight);
    }
    if (fontStyle != null) {
      result = result.copyWith(fontStyle: fontStyle);
    }
    if (color != null) {
      result = result.copyWith(color: color);
    }
    if (fontFamily != null) {
      result = result.copyWith(fontFamily: fontFamily);
    }
    if (letterSpacing != null) {
      result = result.copyWith(letterSpacing: letterSpacing);
    }
    if (wordSpacing != null) {
      result = result.copyWith(wordSpacing: wordSpacing);
    }
    if (height != null) {
      result = result.copyWith(height: height);
    }
    if (decoration != null) {
      result = result.copyWith(decoration: decoration);
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InlineTextStyle &&
        other.fontScale == fontScale &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.color == color &&
        other.fontFamily == fontFamily &&
        other.letterSpacing == letterSpacing &&
        other.wordSpacing == wordSpacing &&
        other.height == height &&
        other.decoration == decoration;
  }

  @override
  int get hashCode => Object.hash(
        fontScale,
        fontWeight,
        fontStyle,
        color,
        fontFamily,
        letterSpacing,
        wordSpacing,
        height,
        decoration,
      );
}

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
    required this.nodes,
    this.baseStyle = InlineTextStyle.empty,
    this.textAlign = TextAlign.left,
    this.lineHeight,
  });

  final String text;
  final List<InlineNode> nodes;
  final InlineTextStyle baseStyle;
  final TextAlign textAlign;
  final double? lineHeight;

  bool get hasInlineContent => nodes.isNotEmpty;

  List<InlineSpanFragment> sliceFragments(
    int start,
    int end, {
    required TextStyle baseStyle,
  }) {
    if (start >= end || text.isEmpty) {
      return const [];
    }

    final fragments = <InlineSpanFragment>[];
    for (final node in nodes) {
      if (node.end <= start || node.start >= end) {
        continue;
      }
      if (node is InlineTextNode) {
        final sliceStart = node.start > start ? node.start : start;
        final sliceEnd = node.end < end ? node.end : end;
        if (sliceEnd <= sliceStart) {
          continue;
        }
        final content = text.substring(sliceStart, sliceEnd);
        if (content.isEmpty) {
          continue;
        }
        final resolvedStyle =
            node.style.isPlain ? baseStyle : node.style.resolve(baseStyle);
        fragments.add(
          InlineSpanFragment.text(
            text: content,
            style: resolvedStyle,
          ),
        );
      } else if (node is InlinePlaceholderNode) {
        if (node.start >= start && node.start < end) {
          fragments.add(
            InlineSpanFragment.image(
              image: node.image,
            ),
          );
        }
      }
    }

    if (fragments.isEmpty) {
      final slice = text.substring(start, end);
      if (slice.isNotEmpty) {
        fragments.add(
          InlineSpanFragment.text(
            text: slice,
            style: baseStyle,
          ),
        );
      }
    }

    return fragments;
  }
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
    required this.fragments,
    required this.textAlign,
    required this.baseStyle,
    required super.spacingBefore,
    required super.spacingAfter,
    this.lineHeight,
  });

  final String text;
  final List<InlineSpanFragment> fragments;
  final TextAlign textAlign;
  final TextStyle baseStyle;
  final double? lineHeight;
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

abstract class InlineNode {
  const InlineNode({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}

class InlineTextNode extends InlineNode {
  const InlineTextNode({
    required super.start,
    required super.end,
    required this.style,
  });

  final InlineTextStyle style;
}

class InlinePlaceholderNode extends InlineNode {
  InlinePlaceholderNode({
    required int position,
    required this.image,
  }) : super(start: position, end: position + 1);

  final InlineImageContent image;
}

class InlineImageContent {
  const InlineImageContent({
    required this.bytes,
    this.intrinsicWidth,
    this.intrinsicHeight,
    this.alignment = PlaceholderAlignment.baseline,
    this.baseline = TextBaseline.alphabetic,
  });

  final Uint8List bytes;
  final double? intrinsicWidth;
  final double? intrinsicHeight;
  final PlaceholderAlignment alignment;
  final TextBaseline baseline;
}

class InlineSpanFragment {
  const InlineSpanFragment.text({
    required this.text,
    required this.style,
  })  : type = InlineFragmentType.text,
        image = null;

  const InlineSpanFragment.image({
    required this.image,
  })  : type = InlineFragmentType.image,
        text = null,
        style = null;

  final InlineFragmentType type;
  final String? text;
  final TextStyle? style;
  final InlineImageContent? image;
}

enum InlineFragmentType {
  text,
  image,
}
