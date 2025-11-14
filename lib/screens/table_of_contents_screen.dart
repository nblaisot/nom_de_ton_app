import 'package:flutter/material.dart';
import 'package:memoreader/l10n/app_localizations.dart';

import '../models/chapter_entry.dart';

class TableOfContentsScreen extends StatelessWidget {
  final List<ChapterEntry> chapters;
  final int currentPage;
  final ValueChanged<int> onChapterSelected;

  const TableOfContentsScreen({
    super.key,
    required this.chapters,
    required this.currentPage,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tableOfContents),
      ),
      body: chapters.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noChaptersAvailable,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isCurrent = currentPage >= chapter.pageIndex &&
                    (index == chapters.length - 1 ||
                        currentPage < chapters[index + 1].pageIndex);

                return ListTile(
                  leading: Icon(
                    isCurrent ? Icons.bookmark : Icons.book_outlined,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    chapter.title,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    l10n.chapter(chapter.index + 1),
                  ),
                  onTap: () {
                    onChapterSelected(chapter.pageIndex);
                    Navigator.pop(context);
                  },
                  selected: isCurrent,
                );
              },
            ),
    );
  }
}
