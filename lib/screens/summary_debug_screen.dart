import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/book_summary_chunk.dart';
import '../services/enhanced_summary_service.dart';
import '../models/book.dart';

class SummaryDebugScreen extends StatefulWidget {
  final Book book;
  final EnhancedSummaryService enhancedSummaryService;

  const SummaryDebugScreen({
    super.key,
    required this.book,
    required this.enhancedSummaryService,
  });

  @override
  State<SummaryDebugScreen> createState() => _SummaryDebugScreenState();
}

class _SummaryDebugScreenState extends State<SummaryDebugScreen> {
  List<BookSummaryChunk> _chunks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntermediateSummaries();
  }

  Future<void> _loadIntermediateSummaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chunks = await widget.enhancedSummaryService.getAllIntermediateSummaries(widget.book.id);
      setState(() {
        _chunks = chunks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading intermediate summaries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text('Résumés intermédiaires (Debug)'),
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chunks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Aucun résumé intermédiaire disponible.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _chunks.length,
                  itemBuilder: (context, index) {
                    final chunk = _chunks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ExpansionTile(
                        title: Text(
                          'Chunk ${chunk.chunkIndex}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Caractères: ${chunk.startCharacterIndex ?? 'N/A'} - ${chunk.endCharacterIndex ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (chunk.createdAt != null)
                              Text(
                                'Créé: ${_formatDate(chunk.createdAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (chunk.tokenCount != null)
                              Text(
                                'Tokens estimés: ${chunk.tokenCount}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: MarkdownBody(
                              data: chunk.summaryText,
                              styleSheet: MarkdownStyleSheet(
                                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      height: 1.6,
                                    ),
                                h1: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

