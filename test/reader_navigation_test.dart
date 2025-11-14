import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoreader/screens/reader/tap_zones.dart';

void main() {
  group('Reader Navigation Gesture Tests', () {
    testWidgets('tap right zone should trigger nextPage action', (WidgetTester tester) async {
      bool nextPageTriggered = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                // Simulate PageView
                Container(width: 1080, height: 1920, color: Colors.white),
                // Simulate the GestureDetector overlay
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          final size = MediaQuery.of(context).size;
                          final action = determineTapAction(details.globalPosition, size);
                          if (action == ReaderTapAction.nextPage) {
                            nextPageTriggered = true;
                          }
                        },
                        child: Container(color: Colors.transparent),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get screen size
      final screenSize = tester.getSize(find.byType(Scaffold));
      final rightThreshold = screenSize.width * 0.67;
      final centerY = screenSize.height / 2;

      // Tap on the right side of the screen
      await tester.tapAt(Offset(rightThreshold + 10, centerY));
      await tester.pump();

      // Verify nextPage was triggered immediately (onTapDown fires immediately)
      expect(nextPageTriggered, isTrue, reason: 'Tapping right should trigger nextPage action immediately');
    });

    testWidgets('tap left zone should trigger previousPage action', (WidgetTester tester) async {
      bool previousPageTriggered = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(width: 1080, height: 1920, color: Colors.white),
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          final size = MediaQuery.of(context).size;
                          final action = determineTapAction(details.globalPosition, size);
                          if (action == ReaderTapAction.previousPage) {
                            previousPageTriggered = true;
                          }
                        },
                        child: Container(color: Colors.transparent),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final screenSize = tester.getSize(find.byType(Scaffold));
      final leftThreshold = screenSize.width * 0.33;
      final centerY = screenSize.height / 2;

      // Tap on the left side
      await tester.tapAt(Offset(leftThreshold - 10, centerY));
      await tester.pump();

      expect(previousPageTriggered, isTrue, reason: 'Tapping left should trigger previousPage action immediately');
    });

    test('determineTapAction returns nextPage for right zone', () {
      const size = Size(1080, 1920);
      final rightThreshold = size.width * 0.67;
      final action = determineTapAction(Offset(rightThreshold + 10, size.height / 2), size);
      expect(action, ReaderTapAction.nextPage);
    });

    test('determineTapAction returns previousPage for left zone', () {
      const size = Size(1080, 1920);
      final leftThreshold = size.width * 0.33;
      final action = determineTapAction(Offset(leftThreshold - 10, size.height / 2), size);
      expect(action, ReaderTapAction.previousPage);
    });
  });

  group('PageView Navigation with GestureDetector', () {
    testWidgets('PageController.animateToPage should change page when called', (WidgetTester tester) async {
      int currentPage = 0;
      final pageController = PageController(initialPage: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: 5,
                  onPageChanged: (index) {
                    currentPage = index;
                  },
                  itemBuilder: (context, index) {
                    return Center(child: Text('Page $index'));
                  },
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      // Simulate next page action
                      if (currentPage < 4 && pageController.hasClients) {
                        pageController.animateToPage(
                          currentPage + 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial page
      expect(find.text('Page 0'), findsOneWidget);
      expect(currentPage, 0);

      // Tap to trigger next page
      final center = tester.getCenter(find.byType(Scaffold));
      await tester.tapAt(center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify we moved to page 1
      expect(find.text('Page 1'), findsOneWidget);
      expect(currentPage, 1);

      pageController.dispose();
    });
  });
}
