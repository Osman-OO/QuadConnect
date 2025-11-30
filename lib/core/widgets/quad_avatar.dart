import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// User avatar with fallback to initials
class QuadAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final bool showBorder;
  final bool isOnline;
  final VoidCallback? onTap;

  const QuadAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.showBorder = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          initials ?? '?',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Small avatar for inline use (comments, lists)
class SmallAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final VoidCallback? onTap;

  const SmallAvatar({super.key, this.imageUrl, this.initials, this.onTap});

  @override
  Widget build(BuildContext context) {
    return QuadAvatar(
      imageUrl: imageUrl,
      initials: initials,
      size: 32,
      onTap: onTap,
    );
  }
}

/// Large avatar for profile pages
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final VoidCallback? onTap;
  final bool isEditable;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.onTap,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QuadAvatar(
          imageUrl: imageUrl,
          initials: initials,
          size: 100,
          showBorder: true,
          onTap: onTap,
        ),
        if (isEditable)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
