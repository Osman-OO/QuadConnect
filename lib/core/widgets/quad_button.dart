import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom button variants for QuadConnect
enum QuadButtonVariant { primary, secondary, outline, text, danger }

/// Reusable button with loading state and variants
class QuadButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final QuadButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;

  const QuadButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = QuadButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case QuadButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );

      case QuadButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: child,
        );

      case QuadButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );

      case QuadButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );

      case QuadButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: child,
        );
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case QuadButtonVariant.primary:
      case QuadButtonVariant.secondary:
      case QuadButtonVariant.danger:
        return AppColors.white;
      case QuadButtonVariant.outline:
      case QuadButtonVariant.text:
        return AppColors.primary;
    }
  }
}

/// Social sign-in button
class SocialSignInButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.label,
    required this.iconAsset,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Using icon instead of image for now
                  const Icon(Icons.g_mobiledata, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
