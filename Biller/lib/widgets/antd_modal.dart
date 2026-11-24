import 'dart:math';
import 'package:flutter/material.dart';
import 'form_helpers.dart';

/// Authentic Ant Design (AntD v5) Modal Dialog Component
/// - Pure white surface with 8px border radius
/// - Subtle #f0f0f0 dividers between header, body, and footer
/// - Top-right sleek close icon (×)
/// - Right-aligned action footer with standard AntD Outlined & Primary buttons
/// - Responsive width constraints
class AntdModal extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;
  final VoidCallback? onClose;

  const AntdModal({
    super.key,
    required this.title,
    this.titleIcon,
    required this.content,
    this.actions,
    this.maxWidth = 520,
    this.onClose,
  });

  /// Show an AntD standard dialog with customized body and actions
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    IconData? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double maxWidth = 520,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => AntdModal(
        title: title,
        titleIcon: titleIcon,
        maxWidth: maxWidth,
        actions: actions,
        onClose: () => Navigator.pop(ctx),
        content: content,
      ),
    );
  }

  /// Show an AntD confirmation / delete dialog
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool isDanger = false,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: min(420.0, MediaQuery.of(ctx).size.width * 0.92),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDanger
                            ? const Color(0xFFFFF1F0)
                            : const Color(0xFFE6F4FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                        size: 18,
                        color: isDanger ? const Color(0xFFFF4D4F) : const Color(0xFF1677FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF595959),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ErpFormWidgets.outlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      text: cancelText,
                    ),
                    const SizedBox(width: 8),
                    if (isDanger)
                      ErpFormWidgets.dangerButton(
                        onPressed: () {
                          Navigator.pop(ctx, true);
                          if (onConfirm != null) onConfirm();
                        },
                        text: confirmText,
                      )
                    else
                      ErpFormWidgets.primaryButton(
                        onPressed: () {
                          Navigator.pop(ctx, true);
                          if (onConfirm != null) onConfirm();
                        },
                        text: confirmText,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = min(maxWidth, screenWidth * 0.94);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFF0F0F0), width: 1),
      ),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AntD Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 16, 16),
              child: Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(titleIcon, size: 18, color: const Color(0xFF1F1F1F)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF8C8C8C)),
                    onPressed: onClose ?? () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    splashRadius: 16,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1),

            // AntD Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: content,
              ),
            ),

            // AntD Modal Footer
            if (actions != null && actions!.isNotEmpty) ...[
              const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((act) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: act,
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
