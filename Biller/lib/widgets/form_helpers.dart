import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable ERP Form Field Widgets strictly enforcing:
/// - Exact 35px height for inputs and buttons
/// - Maximum FontWeight.w600
/// - 4px to 6px border radius
/// - Monochrome Light Gray & Pitch Black enterprise palette
class ErpFormWidgets {
  /// Strict 35px Height Text Field with optional label
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pitchBlack,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
        ],
        SizedBox(
          height: 35,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.pitchBlack,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.zinc500,
              ),
              filled: true,
              fillColor: AppColors.canvas,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 15, color: AppColors.zinc600)
                  : null,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Strict 35px Height Dropdown Field
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pitchBlack,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
        ],
        SizedBox(
          height: 35,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.pitchBlack,
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.zinc700),
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.zinc500,
              ),
              filled: true,
              fillColor: AppColors.canvas,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Strict 35px Height Primary Black Button
  static Widget primaryButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pitchBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Strict 35px Height Outlined Button
  static Widget outlinedButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
  }) {
    return SizedBox(
      height: 35,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pitchBlack,
          side: const BorderSide(color: AppColors.border, width: 1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.pitchBlack),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pitchBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Strict 35px Height Secondary Flat Button (Light Gray)
  static Widget secondaryButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
  }) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.pitchBlack,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.pitchBlack),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.pitchBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status badge (Active / Inactive)
  static Widget statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.12) : AppColors.canvas,
        border: Border.all(
          color: isActive ? Colors.green.shade600 : AppColors.border,
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
              color: isActive ? Colors.green.shade700 : AppColors.zinc500,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade800 : AppColors.zinc600,
            ),
          ),
        ],
      ),
    );
  }
}
