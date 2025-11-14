import 'package:flutter/material.dart';

enum ReaderTapAction {
  showMenu,
  showProgress,
  nextPage,
  previousPage,
  dismissOverlays,
}

ReaderTapAction determineTapAction(Offset position, Size size) {
  final topThreshold = size.height * 0.2;
  final bottomThreshold = size.height * 0.8;
  final leftThreshold = size.width * 0.33;
  final rightThreshold = size.width * 0.67;

  if (position.dy <= topThreshold) {
    return ReaderTapAction.showMenu;
  }
  if (position.dy >= bottomThreshold) {
    return ReaderTapAction.showProgress;
  }
  if (position.dx >= rightThreshold) {
    return ReaderTapAction.nextPage;
  }
  if (position.dx <= leftThreshold) {
    return ReaderTapAction.previousPage;
  }
  return ReaderTapAction.dismissOverlays;
}
