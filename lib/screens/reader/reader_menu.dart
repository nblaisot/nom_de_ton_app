import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memoreader/l10n/app_localizations.dart';

enum ReaderFontScalePreset { decrease, normal, increase }

/// Displays the reader menu as a modal sheet that slides from the top.
Future<void> showReaderMenu({
  required BuildContext context,
  required ReaderFontScalePreset fontScalePreset,
  required ValueChanged<ReaderFontScalePreset> onFontScaleChanged,
  required bool hasChapters,
  required VoidCallback onGoToChapter,
  required VoidCallback onGoToPercentage,
  required VoidCallback onShowSummaryFromBeginning,
  required VoidCallback onShowSummarySinceLastTime,
  required VoidCallback onShowCharactersSummary,
  required VoidCallback onReturnToLibrary,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      void closeMenu() {
        Navigator.of(dialogContext).pop();
      }

      void handleAction(VoidCallback action) {
        closeMenu();
        Future.microtask(action);
      }

      return _ReaderMenuDialog(
        fontScalePreset: fontScalePreset,
        onFontScaleChanged: onFontScaleChanged,
        hasChapters: hasChapters,
        onGoToChapter: () => handleAction(onGoToChapter),
        onGoToPercentage: () => handleAction(onGoToPercentage),
        onShowSummaryFromBeginning:
            () => handleAction(onShowSummaryFromBeginning),
        onShowSummarySinceLastTime:
            () => handleAction(onShowSummarySinceLastTime),
        onShowCharactersSummary: () => handleAction(onShowCharactersSummary),
        onReturnToLibrary: () => handleAction(onReturnToLibrary),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(curvedAnimation);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class _ReaderMenuDialog extends StatefulWidget {
  const _ReaderMenuDialog({
    required this.fontScalePreset,
    required this.onFontScaleChanged,
    required this.hasChapters,
    required this.onGoToChapter,
    required this.onGoToPercentage,
    required this.onShowSummaryFromBeginning,
    required this.onShowSummarySinceLastTime,
    required this.onShowCharactersSummary,
    required this.onReturnToLibrary,
  });

  final ReaderFontScalePreset fontScalePreset;
  final ValueChanged<ReaderFontScalePreset> onFontScaleChanged;
  final bool hasChapters;
  final VoidCallback onGoToChapter;
  final VoidCallback onGoToPercentage;
  final VoidCallback onShowSummaryFromBeginning;
  final VoidCallback onShowSummarySinceLastTime;
  final VoidCallback onShowCharactersSummary;
  final VoidCallback onReturnToLibrary;

  @override
  State<_ReaderMenuDialog> createState() => _ReaderMenuDialogState();
}

class _ReaderMenuDialogState extends State<_ReaderMenuDialog> {
  late ReaderFontScalePreset _selectedPreset;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.fontScalePreset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final summariesTitle = l10n?.summariesSectionTitle ?? 'Summaries';
    final fromBeginningLabel = l10n?.summaryFromBeginning ?? 'From the Beginning';
    final sinceLastTimeLabel = l10n?.summarySinceLastTime ?? 'Since last time';
    final charactersLabel = l10n?.summaryCharacters ?? 'Characters';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
            elevation: 12,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Options de lecture',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Taille du texte'),
                    const SizedBox(height: 8),
                    _FontScaleSelector(
                      selectedPreset: _selectedPreset,
                      onPresetChanged: (preset) {
                        setState(() => _selectedPreset = preset);
                        widget.onFontScaleChanged(preset);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (widget.hasChapters)
                      ListTile(
                        leading: const Icon(Icons.list),
                        title: const Text('Aller au chapitre'),
                        onTap: widget.onGoToChapter,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ListTile(
                      leading: const Icon(Icons.percent),
                      title: const Text('Aller à un pourcentage'),
                      onTap: widget.onGoToPercentage,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summariesTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.auto_stories),
                      title: Text(fromBeginningLabel),
                      onTap: widget.onShowSummaryFromBeginning,
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.history_toggle_off),
                      title: Text(sinceLastTimeLabel),
                      onTap: widget.onShowSummarySinceLastTime,
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_outline),
                      title: Text(charactersLabel),
                      onTap: widget.onShowCharactersSummary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.arrow_back),
                      title: const Text('Retour à la librairie'),
                      onTap: widget.onReturnToLibrary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FontScaleSelector extends StatelessWidget {
  const _FontScaleSelector({
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  final ReaderFontScalePreset selectedPreset;
  final ValueChanged<ReaderFontScalePreset> onPresetChanged;

  @override
  Widget build(BuildContext context) {
    final presets = ReaderFontScalePreset.values;
    final labels = <ReaderFontScalePreset, String>{
      ReaderFontScalePreset.decrease: '-',
      ReaderFontScalePreset.normal: 'Normal',
      ReaderFontScalePreset.increase: '+',
    };
    final isSelected = presets.map((preset) => preset == selectedPreset).toList();
    return Center(
      child: ToggleButtons(
        isSelected: isSelected,
        borderRadius: BorderRadius.circular(12),
        constraints: const BoxConstraints(minHeight: 40, minWidth: 60),
        onPressed: (index) => onPresetChanged(presets[index]),
        children: presets
            .map((preset) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(labels[preset]!)),
                )
            .toList(),
      ),
    );
  }
}
