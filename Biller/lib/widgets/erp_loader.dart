import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean, high-performance, enterprise AntD-style Loader & Spinner
class ErpLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ErpLoader({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.pitchBlack),
      ),
    );
  }

  /// Full-screen or Container overlay with loader and status text
  static Widget overlay({
    required String message,
    double size = 28,
  }) {
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErpLoader(size: size, strokeWidth: 2.5),
              const SizedBox(height: 12),
              Text(
                message,
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
      ),
    );
  }
}
