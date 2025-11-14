import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'document_model.dart';

typedef WordSplitter = List<String> Function(String text);

/// Pagination engine that fills pages word by word, ensuring no words are lost or repeated.
class PaginationEngine {
  PaginationEngine({
    required List<DocumentBlock> blocks,
    required TextStyle baseTextStyle,
    required double maxWidth,
    required double maxHeight,
    required WordSplitter wordSplitter,
  })  : _blocks = blocks,
        _baseTextStyle = baseTextStyle,
        _maxWidth = maxWidth,
        _maxHeight = maxHeight,
        _wordSplitter = wordSplitter {
    _buildRuns();
  }

  final List<DocumentBlock> _blocks;
  final TextStyle _baseTextStyle;
  final double _maxWidth;
  final double _maxHeight;
  final WordSplitter _wordSplitter;

  late final List<_ContentRun> _runs;
  late final List<int> _runWordOffsets;
  int _totalWords = 0;

  int get totalWords => _totalWords;

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
        (_maxHeight - maxHeight).abs() < 0.5;
  }

  /// Layout a page starting from the given word index.
  /// Returns null if no content can be added.
  /// Adds words one by one, checking after each word if the limit is reached.
  PageContent? layoutPage(int startWordIndex) {
    if (_runs.isEmpty || _totalWords == 0 || startWordIndex >= _totalWords) {
      return null;
    }

    final pointer = _resolvePointer(startWordIndex);
    if (pointer == null) {
      return null;
    }

    final blocks = <PageBlock>[];
    int? chapterIndex;
    int currentRunIndex = pointer.runIndex;
    int currentWordOffset = pointer.wordOffset;
    int globalWordIndex = startWordIndex;

    // Current text block being built
    String? currentTextBlock;
    TextStyle? currentTextStyle;
    TextAlign? currentTextAlign;
    double? currentSpacingBefore;
    int? currentBlockStartWordIndex;

    // Fill the page word by word
    while (currentRunIndex < _runs.length) {
      final run = _runs[currentRunIndex];
      chapterIndex ??= run.chapterIndex;

      if (run.type == _RunType.text) {
        // Process text run word by word
        while (currentWordOffset < run.wordCount) {
          // Check if we need to start a new text block
          if (currentTextBlock == null) {
            // Start a new text block
            final spacingBefore = blocks.isEmpty && currentWordOffset == 0 ? run.spacingBefore : 0.0;
            currentSpacingBefore = spacingBefore;
            currentTextStyle = run.textStyle;
            currentTextAlign = run.textAlign;
            currentBlockStartWordIndex = globalWordIndex;
            currentTextBlock = '';
          }

          // Add the next word
          final wordToAdd = run.words[currentWordOffset];
          final newText = currentTextBlock! + wordToAdd;
          
          // Measure the height with this word added
          final painter = TextPainter(
            text: TextSpan(text: newText, style: currentTextStyle),
            textAlign: currentTextAlign ?? TextAlign.left,
            textDirection: TextDirection.ltr,
            maxLines: null,
          )..layout(maxWidth: _maxWidth);

          final textHeight = painter.height;
          
          // Check if we'll complete the run with this word
          final willCompleteRun = currentWordOffset + 1 >= run.wordCount;
          final spacingAfter = willCompleteRun ? run.spacingAfter : 0.0;
          
          // Calculate total height EXACTLY as the test does
          // Simulate what the page would look like if we add this word
          double totalHeight = 0.0;
          
          // Add all finalized blocks
          for (final block in blocks) {
            totalHeight += block.spacingBefore;
            if (block is TextPageBlock) {
              final blockPainter = TextPainter(
                text: TextSpan(text: block.text, style: block.style),
                textAlign: block.textAlign,
                textDirection: TextDirection.ltr,
                maxLines: null,
              )..layout(maxWidth: _maxWidth);
              totalHeight += blockPainter.height;
            } else if (block is ImagePageBlock) {
              totalHeight += block.height;
            }
            totalHeight += block.spacingAfter;
          }
          
          // Add the current block being built WITH the new word
          final isNewBlock = currentTextBlock!.isEmpty;
          final blockSpacingBefore = isNewBlock ? (currentSpacingBefore ?? 0.0) : 0.0;
          totalHeight += blockSpacingBefore + textHeight + spacingAfter;

          // Check if adding this word exceeds the limit
          if (totalHeight > _maxHeight) {
            // This word doesn't fit - stop here
            // If we have accumulated words, create a block with them
            if (currentTextBlock!.isNotEmpty && currentBlockStartWordIndex != null) {
              // Measure the accumulated text (without the word that doesn't fit)
              final finalPainter = TextPainter(
                text: TextSpan(text: currentTextBlock!, style: currentTextStyle),
                textAlign: currentTextAlign ?? TextAlign.left,
                textDirection: TextDirection.ltr,
                maxLines: null,
              )..layout(maxWidth: _maxWidth);

              final blockSpacingBeforeFinal = currentSpacingBefore ?? 0.0;
              blocks.add(
                TextPageBlock(
                  text: currentTextBlock!,
                  style: currentTextStyle!,
                  textAlign: currentTextAlign!,
                  spacingBefore: blockSpacingBeforeFinal,
                  spacingAfter: 0.0,
                ),
              );
            }
            // Stop filling this page - the word at currentWordOffset will start the next page
            break;
          }

          // This word fits, so add it to the current block
          currentTextBlock = newText;
          globalWordIndex++;
          currentWordOffset++;

          // If we completed the run, verify one more time before finalizing
          if (willCompleteRun) {
            // Re-calculate total height to ensure we don't exceed when finalizing
            double finalTotalHeight = 0.0;
            for (final block in blocks) {
              finalTotalHeight += block.spacingBefore;
              if (block is TextPageBlock) {
                final blockPainter = TextPainter(
                  text: TextSpan(text: block.text, style: block.style),
                  textAlign: block.textAlign,
                  textDirection: TextDirection.ltr,
                  maxLines: null,
                )..layout(maxWidth: _maxWidth);
                finalTotalHeight += blockPainter.height;
              } else if (block is ImagePageBlock) {
                finalTotalHeight += block.height;
              }
              finalTotalHeight += block.spacingAfter;
            }
            // Add the block we're about to finalize
            final blockSpacingBeforeFinal = currentSpacingBefore ?? 0.0;
            finalTotalHeight += blockSpacingBeforeFinal + textHeight + spacingAfter;
            
            // If finalizing would exceed, don't add spacingAfter or remove last word
            if (finalTotalHeight > _maxHeight) {
              // Try without spacingAfter
              final heightWithoutSpacing = finalTotalHeight - spacingAfter;
              if (heightWithoutSpacing > _maxHeight) {
                // Even without spacingAfter it exceeds - remove the last word
                currentTextBlock = currentTextBlock!.substring(0, currentTextBlock!.length - wordToAdd.length);
                globalWordIndex--;
                currentWordOffset--;
                
                if (currentTextBlock!.isNotEmpty && currentBlockStartWordIndex != null) {
                  final finalPainter = TextPainter(
                    text: TextSpan(text: currentTextBlock!, style: currentTextStyle),
                    textAlign: currentTextAlign ?? TextAlign.left,
                    textDirection: TextDirection.ltr,
                    maxLines: null,
                  )..layout(maxWidth: _maxWidth);
                  
                  blocks.add(
                    TextPageBlock(
                      text: currentTextBlock!,
                      style: currentTextStyle!,
                      textAlign: currentTextAlign!,
                      spacingBefore: blockSpacingBeforeFinal,
                      spacingAfter: 0.0,
                    ),
                  );
                }
                break;
              } else {
                // Add without spacingAfter
                blocks.add(
                  TextPageBlock(
                    text: currentTextBlock!,
                    style: currentTextStyle!,
                    textAlign: currentTextAlign!,
                    spacingBefore: blockSpacingBeforeFinal,
                    spacingAfter: 0.0,
                  ),
                );
              }
            } else {
              // Safe to add with spacingAfter
              blocks.add(
                TextPageBlock(
                  text: currentTextBlock!,
                  style: currentTextStyle!,
                  textAlign: currentTextAlign!,
                  spacingBefore: blockSpacingBeforeFinal,
                  spacingAfter: spacingAfter,
                ),
              );
            }
            currentTextBlock = null;
            currentRunIndex++;
            currentWordOffset = 0;
            break; // Move to next run
          }
        }

        // If we broke out of the word loop but didn't complete the run, stop filling the page
        if (currentWordOffset < run.wordCount) {
          break;
        }
      } else {
        // Try to add image
        final spacingBefore = blocks.isEmpty ? run.spacingBefore : 0.0;
        final spacingAfter = run.spacingAfter;
        
        // Calculate total height of existing blocks
        double existingHeight = 0.0;
        for (final block in blocks) {
          existingHeight += block.spacingBefore;
          if (block is TextPageBlock) {
            final blockPainter = TextPainter(
              text: TextSpan(text: block.text, style: block.style),
              textAlign: block.textAlign,
              textDirection: TextDirection.ltr,
              maxLines: null,
            )..layout(maxWidth: _maxWidth);
            existingHeight += blockPainter.height;
          } else if (block is ImagePageBlock) {
            existingHeight += block.height;
          }
          existingHeight += block.spacingAfter;
        }
        
        final availableHeight = _maxHeight - existingHeight - spacingBefore - spacingAfter;

        if (availableHeight <= 0) {
          break;
        }

        final fittedHeight = _computeFittedImageHeight(run, availableHeight);
        if (fittedHeight <= 0) {
          break;
        }

        final totalHeight = existingHeight + spacingBefore + fittedHeight + spacingAfter;
        if (totalHeight > _maxHeight) {
          break;
        }

        blocks.add(
          ImagePageBlock(
            bytes: run.imageBytes!,
            height: fittedHeight,
            spacingBefore: spacingBefore,
            spacingAfter: spacingAfter,
          ),
        );

        globalWordIndex += 1;
        currentRunIndex++;
        currentWordOffset = 0;
      }
    }

    // Finalize any remaining text block
    if (currentTextBlock != null && currentTextBlock!.isNotEmpty && currentBlockStartWordIndex != null) {
      final finalPainter = TextPainter(
        text: TextSpan(text: currentTextBlock!, style: currentTextStyle),
        textAlign: currentTextAlign ?? TextAlign.left,
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: _maxWidth);

      final blockSpacingBeforeFinal = currentSpacingBefore ?? 0.0;
      blocks.add(
        TextPageBlock(
          text: currentTextBlock!,
          style: currentTextStyle!,
          textAlign: currentTextAlign!,
          spacingBefore: blockSpacingBeforeFinal,
          spacingAfter: 0.0,
        ),
      );
    }

    if (blocks.isEmpty || globalWordIndex <= startWordIndex) {
      return null;
    }

    return PageContent(
      blocks: blocks,
      chapterIndex: chapterIndex ?? 0,
      startWordIndex: startWordIndex,
      endWordIndex: globalWordIndex - 1, // Last word that was added
    );
  }

  /// Find the start word index for the previous page that ends just before currentStartWordIndex.
  int? findPreviousPageStart(int currentStartWordIndex) {
    if (_totalWords == 0 || currentStartWordIndex <= 0) {
      return null;
    }

    final targetEnd = currentStartWordIndex - 1;
    int low = 0;
    int high = targetEnd;
    int? best;

    while (low <= high) {
      final mid = (low + high) >> 1;
      final page = layoutPage(mid);
      if (page == null) {
        break;
      }

      if (page.endWordIndex > targetEnd) {
        high = mid - 1;
      } else {
        best = mid;
        if (page.endWordIndex == targetEnd) {
          break;
        }
        low = mid + 1;
      }
    }

    return best;
  }

  void _buildRuns() {
    final runs = <_ContentRun>[];
    final offsets = <int>[];
    int wordCounter = 0;

    for (final block in _blocks) {
      if (block is TextDocumentBlock) {
        final words = _wordSplitter(block.text);
        if (words.isEmpty) {
          continue;
        }

        final style = _baseTextStyle.copyWith(
          fontSize: (_baseTextStyle.fontSize ?? 16) * block.fontScale,
          fontWeight: block.fontWeight,
          fontStyle: block.fontStyle,
        );

        offsets.add(wordCounter);
        runs.add(_ContentRun.text(
          chapterIndex: block.chapterIndex,
          words: words,
          textStyle: style,
          textAlign: block.textAlign,
          spacingBefore: block.spacingBefore,
          spacingAfter: block.spacingAfter,
        ));
        wordCounter += words.length;
      } else if (block is ImageDocumentBlock) {
        offsets.add(wordCounter);
        runs.add(_ContentRun.image(
          chapterIndex: block.chapterIndex,
          imageBytes: block.bytes,
          intrinsicWidth: block.intrinsicWidth,
          intrinsicHeight: block.intrinsicHeight,
          spacingBefore: block.spacingBefore,
          spacingAfter: block.spacingAfter,
        ));
        wordCounter += 1; // Images count as one word
      }
    }

    _runs = runs;
    _runWordOffsets = offsets;
    _totalWords = wordCounter;
  }

  _Pointer? _resolvePointer(int wordIndex) {
    if (wordIndex < 0 || wordIndex >= _totalWords) {
      return null;
    }

    int low = 0;
    int high = _runs.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final start = _runWordOffsets[mid];
      final end = start + _runs[mid].wordCount;
      if (wordIndex < start) {
        high = mid - 1;
      } else if (wordIndex >= end) {
        low = mid + 1;
      } else {
        return _Pointer(runIndex: mid, wordOffset: wordIndex - start);
      }
    }
    return null;
  }

  /// Compute the height of an image fitted to available space.
  /// Constrains width first, then height if needed.
  double _computeFittedImageHeight(_ContentRun run, double availableHeight) {
    final intrinsicWidth = run.intrinsicWidth ?? _maxWidth;
    final intrinsicHeight = run.intrinsicHeight ?? (_maxWidth * 0.6);
    if (intrinsicWidth <= 0 || intrinsicHeight <= 0) {
      return math.min(availableHeight, _maxHeight * 0.6);
    }

    // Scale to fit width first
    double fittedWidth = math.min(intrinsicWidth, _maxWidth);
    double fittedHeight = (fittedWidth / intrinsicWidth) * intrinsicHeight;

    // Then scale height if needed
    if (fittedHeight > availableHeight) {
      fittedHeight = availableHeight;
      fittedWidth = (fittedHeight / intrinsicHeight) * intrinsicWidth;
      if (fittedWidth > _maxWidth) {
        fittedWidth = _maxWidth;
        fittedHeight = (fittedWidth / intrinsicWidth) * intrinsicHeight;
      }
    }

    return fittedHeight;
  }
}

class _Pointer {
  _Pointer({required this.runIndex, required this.wordOffset});

  final int runIndex;
  final int wordOffset;
}

enum _RunType { text, image }

class _ContentRun {
  _ContentRun.text({
    required this.chapterIndex,
    required this.words,
    required this.textStyle,
    required this.textAlign,
    required this.spacingBefore,
    required this.spacingAfter,
  })  : type = _RunType.text,
        imageBytes = null,
        intrinsicWidth = null,
        intrinsicHeight = null;

  _ContentRun.image({
    required this.chapterIndex,
    required this.imageBytes,
    required this.intrinsicWidth,
    required this.intrinsicHeight,
    required this.spacingBefore,
    required this.spacingAfter,
  })  : type = _RunType.image,
        words = const [],
        textStyle = const TextStyle(),
        textAlign = TextAlign.left;

  final _RunType type;
  final int chapterIndex;
  final List<String> words;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final Uint8List? imageBytes;
  final double? intrinsicWidth;
  final double? intrinsicHeight;
  final double spacingBefore;
  final double spacingAfter;

  int get wordCount => type == _RunType.text ? words.length : 1;
}
