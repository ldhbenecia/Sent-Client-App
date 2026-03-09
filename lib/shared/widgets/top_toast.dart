import 'dart:async';
import 'package:flutter/material.dart';

OverlayEntry? _activeTopToast;
Timer? _topToastTimer;

void showTopToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _topToastTimer?.cancel();
  if (_activeTopToast?.mounted ?? false) {
    _activeTopToast!.remove();
  }

  final top = MediaQuery.paddingOf(context).top + kToolbarHeight + 12;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: top,
      left: 14,
      right: 14,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xD91C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  _activeTopToast = entry;
  _topToastTimer = Timer(duration, () {
    if (entry.mounted) entry.remove();
    if (identical(_activeTopToast, entry)) {
      _activeTopToast = null;
      _topToastTimer = null;
    }
  });
}
