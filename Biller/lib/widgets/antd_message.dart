import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AntdMessageType { success, error, info, warning }

/// Ant Design (AntD) style top-floating notification toast
/// - Slides down smoothly from top center
/// - Elevated pill card with crisp icons, light gray surface, and subtle shadow
/// - Auto-dismisses smoothly after duration
class AntdMessage {
  static final List<OverlayEntry> _activeEntries = [];

  static void success(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 2500)}) {
    _show(context, message, AntdMessageType.success, duration);
  }

  static void error(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 3000)}) {
    _show(context, message, AntdMessageType.error, duration);
  }

  static void info(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 2500)}) {
    _show(context, message, AntdMessageType.info, duration);
  }

  static void warning(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 2800)}) {
    _show(context, message, AntdMessageType.warning, duration);
  }

  static void _show(BuildContext context, String message, AntdMessageType type, Duration duration) {
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    // Clear any existing active message toasts so they don't stack awkwardly
    for (final entry in _activeEntries) {
      try {
        entry.remove();
      } catch (_) {}
    }
    _activeEntries.clear();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (ctx) => _AntdMessageWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          try {
            overlayEntry.remove();
            _activeEntries.remove(overlayEntry);
          } catch (_) {}
        },
      ),
    );

    _activeEntries.add(overlayEntry);
    overlayState.insert(overlayEntry);
  }
}

class _AntdMessageWidget extends StatefulWidget {
  final String message;
  final AntdMessageType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AntdMessageWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AntdMessageWidget> createState() => _AntdMessageWidgetState();
}

class _AntdMessageWidgetState extends State<_AntdMessageWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (IconData, Color) _getTypeConfig() {
    switch (widget.type) {
      case AntdMessageType.success:
        return (Icons.check_circle, const Color(0xFF52C41A)); // AntD Green
      case AntdMessageType.error:
        return (Icons.cancel, const Color(0xFFFF4D4F)); // AntD Red
      case AntdMessageType.warning:
        return (Icons.warning_amber_rounded, const Color(0xFFFAAD14)); // AntD Orange
      case AntdMessageType.info:
        return (Icons.info, const Color(0xFF1890FF)); // AntD Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor) = _getTypeConfig();

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconData, size: 16, color: iconColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.pitchBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
