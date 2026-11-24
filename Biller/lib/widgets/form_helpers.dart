import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Authentic Ant Design (AntD v5) Form Field Widgets strictly enforcing:
/// - Exact 40px height for inputs, selects, and buttons
/// - Pure White (#ffffff) backgrounds with #d9d9d9 neutral borders
/// - 6px border radius (AntD standard)
/// - Typography: 13px with #1f1f1f text and #bfbfbf placeholders
/// - Clean, elevated dropdown popups with 8px radius and white surface
class ErpFormWidgets {
  // AntD Tokens
  static const Color borderNeutral = Color(0xFFD9D9D9);
  static const Color borderHover = Color(0xFF404040);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF595959);
  static const Color textPlaceholder = Color(0xFFBFBFBF);
  static const Color dangerRed = Color(0xFFFF4D4F);
  static const Color dangerBg = Color(0xFFFFF1F0);
  static const Color dangerBorder = Color(0xFFFFA39E);

  /// AntD Input: 40px Height, Pure White, 6px Radius, 1px #d9d9d9 border
  static Widget textField({
    required TextEditingController controller,
    String? hintText,
    String? label,
    IconData? prefixIcon,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dangerRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textPlaceholder,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 16, color: const Color(0xFF8C8C8C))
                  : null,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: borderNeutral, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: borderNeutral, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// AntD Select: 40px Height, Pure White, 6px Radius, Custom Chevron, Elevated White Popup
  static Widget dropdownField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? label,
    String? hintText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dangerRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            elevation: 4,
            menuMaxHeight: 320,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF8C8C8C),
            ),
            isDense: true,
            isExpanded: true,
            alignment: AlignmentDirectional.centerStart,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textPlaceholder,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: borderNeutral, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: borderNeutral, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// AntD Primary Button: 40px Height, Pitch Black, 6px Radius, Crisp White Text
  static Widget primaryButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pitchBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          shadowColor: Colors.black.withValues(alpha: 0.15),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// AntD Default / Outlined Button: 40px Height, Pure White Surface, #d9d9d9 Border, 6px Radius
  static Widget outlinedButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderNeutral, width: 1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: const Color(0xFF595959)),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AntD Danger Button: 40px Height, AntD Red #ff4d4f, 6px Radius, Crisp White Text
  static Widget dangerButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: dangerRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AntD Secondary / Subtle Button: 40px Height, Light Gray #f5f5f5, #d9d9d9 Border
  static Widget secondaryButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
  }) {
    return SizedBox(
      height: 40,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: borderNeutral, width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AntD Status Tag / Badge (Active: #f6ffed green tag / Inactive: #fafafa neutral tag)
  static Widget statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF6FFED) : const Color(0xFFFAFAFA),
        border: Border.all(
          color: isActive ? const Color(0xFFB7EB8F) : borderNeutral,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF52C41A) : const Color(0xFFBFBFBF),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF389E0D) : const Color(0xFF8C8C8C),
            ),
          ),
        ],
      ),
    );
  }
}
