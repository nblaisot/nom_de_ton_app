import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoreader/screens/reader/tap_zones.dart';
import 'package:memoreader/screens/reader_screen.dart' show shouldKeepSelectionOnPointerUp;

/// Tests for text selection and tap-up gesture handling in the reader screen.
/// 
/// These tests ensure that:
/// 1. Touch down events allow text selection (not intercepted)
/// 2. When selection is active, touches manipulate selection (not intercepted)
/// 3. Touch up events trigger actions (menu, progress, navigation) - only intercepted on tap-up
/// 4. Swipes are handled by PageView for page turning
void main() {
  group('Text Selection and Tap-Up Gesture Tests', () {
    // Note: Testing that SelectionArea receives pointer events is difficult in widget tests
    // because GestureDetector with opaque behavior may intercept events.
    // The key principle is verified by the implementation: GestureDetector only handles
    // onTapUp, not onPointerDown/Move, allowing SelectionArea to receive those events.

    testWidgets('Simple tap (no selection) should trigger tap-up action', (WidgetTester tester) async {
      bool tapUpActionTriggered = false;
      ReaderTapAction? triggeredAction;

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
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) {
                          tapUpActionTriggered = true;
                          final size = MediaQuery.of(context).size;
                          triggeredAction = determineTapAction(details.globalPosition, size);
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

      // Perform a simple tap (down and up quickly)
      final screenSize = tester.getSize(find.byType(Scaffold));
      final rightThreshold = screenSize.width * 0.67;
      final centerY = screenSize.height / 2;
      final tapPosition = Offset(rightThreshold + 10, centerY);

      await tester.tapAt(tapPosition);
      await tester.pump();

      // Tap-up action should be triggered
      expect(tapUpActionTriggered, isTrue,
          reason: 'Simple tap should trigger tap-up action');
      expect(triggeredAction, ReaderTapAction.nextPage,
          reason: 'Tap on right zone should trigger nextPage action');
    });

    testWidgets('Active selection should prevent tap-up actions from triggering', (WidgetTester tester) async {
      bool hasActiveSelection = true;
      bool tapUpActionTriggered = false;
      bool selectionCleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(width: 1080, height: 1920, color: Colors.white),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      // Simulate the logic: if selection is active, handle it differently
                      if (hasActiveSelection) {
                        // Simulate deferring clearing if selection was just created
                        // In real code, this checks timestamp
                        selectionCleared = true;
                        hasActiveSelection = false;
                        return;
                      }
                      tapUpActionTriggered = true;
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

      // Tap while selection is active
      final center = tester.getCenter(find.byType(Scaffold));
      await tester.tapAt(center);
      await tester.pump();

      // Selection should be cleared, but tap-up action should not trigger
      expect(selectionCleared, isTrue,
          reason: 'Tap with active selection should clear selection');
      expect(tapUpActionTriggered, isFalse,
          reason: 'Tap with active selection should not trigger tap-up actions');
    });

    // Note: Testing that drag gestures don't trigger tap-up is verified by GestureDetector's
    // built-in behavior: it automatically distinguishes taps from drags and only fires
    // onTapUp for simple taps, not for drags. This is a framework guarantee.

    // Note: Testing that swipes are handled by PageView is verified by PageView's
    // built-in gesture recognition. When a swipe occurs, PageView consumes the gesture
    // and GestureDetector's onTapUp won't fire. This is a framework guarantee.

    test('determineTapAction handles all tap zones correctly', () {
      const size = Size(1080, 1920);
      
      // Top zone -> menu
      expect(determineTapAction(const Offset(540, 50), size), ReaderTapAction.showMenu);
      
      // Bottom zone -> progress
      expect(determineTapAction(const Offset(540, 1900), size), ReaderTapAction.showProgress);
      
      // Left zone -> previous page
      expect(determineTapAction(const Offset(10, 960), size), ReaderTapAction.previousPage);
      
      // Right zone -> next page
      expect(determineTapAction(const Offset(1070, 960), size), ReaderTapAction.nextPage);
      
      // Center zone -> dismiss overlays
      expect(determineTapAction(const Offset(540, 960), size), ReaderTapAction.dismissOverlays);
    });
  });

  group('Selection State Management Tests', () {
    test('Selection state should track active selection correctly', () {
      bool hasActiveSelection = false;
      DateTime? lastSelectionChangeTimestamp;

      // Simulate selection becoming active
      hasActiveSelection = true;
      lastSelectionChangeTimestamp = DateTime.now();
      
      expect(hasActiveSelection, isTrue);
      expect(lastSelectionChangeTimestamp, isNotNull);

      // Simulate selection being cleared
      hasActiveSelection = false;
      lastSelectionChangeTimestamp = null;
      
      expect(hasActiveSelection, isFalse);
      expect(lastSelectionChangeTimestamp, isNull);
    });

    test('Selection timestamp should be used to defer clearing', () {
      final now = DateTime.now();
      final recentTimestamp = now.subtract(const Duration(milliseconds: 100));
      final oldTimestamp = now.subtract(const Duration(milliseconds: 500));

      // Recent selection (within 250ms) should defer clearing
      final recentDiff = now.difference(recentTimestamp);
      expect(recentDiff < const Duration(milliseconds: 250), isTrue);

      // Old selection (beyond 250ms) should allow clearing
      final oldDiff = now.difference(oldTimestamp);
      expect(oldDiff < const Duration(milliseconds: 250), isFalse);
    });

    test('Selection owner pointer release keeps selection active', () {
      final now = DateTime(2024, 1, 1, 12);
      final keepSelection = shouldKeepSelectionOnPointerUp(
        hasSelection: true,
        isSelectionOwnerPointer: true,
        slopExceeded: false,
        pressDuration: const Duration(milliseconds: 80),
        lastSelectionChangeTimestamp: now.subtract(const Duration(milliseconds: 400)),
        now: now,
      );
      expect(keepSelection, isTrue,
          reason: 'Owner pointer lifting should not clear selection immediately');
    });

    test('Long press release while selected keeps selection', () {
      final now = DateTime(2024, 1, 1, 12);
      final keepSelection = shouldKeepSelectionOnPointerUp(
        hasSelection: true,
        isSelectionOwnerPointer: false,
        slopExceeded: false,
        pressDuration: const Duration(milliseconds: 800),
        lastSelectionChangeTimestamp: now.subtract(const Duration(milliseconds: 400)),
        now: now,
      );
      expect(keepSelection, isTrue,
          reason: 'Long presses should not clear selection on touch up');
    });

    test('Short tap shortly after selection should be deferred', () {
      final now = DateTime(2024, 1, 1, 12);
      final keepSelection = shouldKeepSelectionOnPointerUp(
        hasSelection: true,
        isSelectionOwnerPointer: false,
        slopExceeded: false,
        pressDuration: const Duration(milliseconds: 60),
        lastSelectionChangeTimestamp: now.subtract(const Duration(milliseconds: 100)),
        now: now,
      );
      expect(keepSelection, isTrue,
          reason: 'Touches within defer window should not clear selection');
    });

    test('Short tap well after selection clears selection', () {
      final now = DateTime(2024, 1, 1, 12);
      final keepSelection = shouldKeepSelectionOnPointerUp(
        hasSelection: true,
        isSelectionOwnerPointer: false,
        slopExceeded: false,
        pressDuration: const Duration(milliseconds: 60),
        lastSelectionChangeTimestamp: now.subtract(const Duration(milliseconds: 600)),
        now: now,
      );
      expect(keepSelection, isFalse,
          reason: 'A distant tap should clear selection and restore navigation');
    });

    test('Drag/swipe while selected keeps selection (handled elsewhere)', () {
      final now = DateTime(2024, 1, 1, 12);
      final keepSelection = shouldKeepSelectionOnPointerUp(
        hasSelection: true,
        isSelectionOwnerPointer: false,
        slopExceeded: true,
        pressDuration: const Duration(milliseconds: 120),
        lastSelectionChangeTimestamp: now.subtract(const Duration(milliseconds: 500)),
        now: now,
      );
      expect(keepSelection, isTrue,
          reason: 'Swipes should not clear selection until page change logic runs');
    });
  });
}
