import 'package:flutter/material.dart';
import 'dart:async';
import '../services/app_state_service.dart';
import '../services/book_service.dart';
import '../models/book.dart';
import 'library_screen.dart';
import 'reader_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppStateService _appStateService = AppStateService();
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Book? bookToOpen;
    try {
      final lastBookId = await _appStateService.getLastOpenedBookId();
      if (lastBookId != null) {
        bookToOpen = await _bookService.getBookById(lastBookId);
        if (bookToOpen == null) {
          await _appStateService.clearLastOpenedBook();
        }
      }
    } catch (e) {
      debugPrint('Failed to determine last opened book: $e');
    }

    if (!mounted) return;

    if (bookToOpen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(book: bookToOpen!),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LibraryScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/memoreader.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found - show a placeholder
                  return Icon(
                    Icons.menu_book,
                    size: 150,
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
              const SizedBox(height: 32),
              // App name
              Text(
                'Memoreader',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              // Tagline
              Text(
                'Remember what you\'ve read',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

