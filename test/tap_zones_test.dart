import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoreader/screens/reader/tap_zones.dart';

void main() {
  test('top region triggers menu', () {
    const size = Size(1080, 1920);
    final action = determineTapAction(const Offset(100, 50), size);
    expect(action, ReaderTapAction.showMenu);
  });

  test('bottom region toggles progress', () {
    const size = Size(1080, 1920);
    final action = determineTapAction(const Offset(540, 1900), size);
    expect(action, ReaderTapAction.showProgress);
  });

  test('left region goes to previous page', () {
    const size = Size(1080, 1920);
    final action = determineTapAction(const Offset(10, 800), size);
    expect(action, ReaderTapAction.previousPage);
  });

  test('right region goes to next page', () {
    const size = Size(1080, 1920);
    final action = determineTapAction(const Offset(1070, 800), size);
    expect(action, ReaderTapAction.nextPage);
  });

  test('center dismisses overlays', () {
    const size = Size(1080, 1920);
    final action = determineTapAction(const Offset(540, 960), size);
    expect(action, ReaderTapAction.dismissOverlays);
  });
}
