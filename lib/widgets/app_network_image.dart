import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.fallbackIcon = Icons.toys_rounded,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    final fullUrl = AppConstants.imageUrl(imageUrl);
    print('IMAGE FROM API: $imageUrl');
    print('FULL IMAGE URL: $fullUrl');
    if (imageUrl == null || imageUrl!.isEmpty) {
      child = _buildFallback();
    } else {
      child = CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _buildShimmer(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.border,
      child: Icon(fallbackIcon, color: AppColors.textMuted, size: 32),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.border,
        gradient: LinearGradient(
          colors: [AppColors.border, AppColors.borderMed, AppColors.border],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;

  const UserAvatar({super.key, this.imageUrl, this.size = 40, this.name});

  @override
  Widget build(BuildContext context) {
    final fullUrl = AppConstants.imageUrl(imageUrl);
    print('IMAGE FROM API: $imageUrl');
    print('FULL IMAGE URL: $fullUrl');
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: fullUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitials(),
          errorWidget: (_, __, ___) => _buildInitials(),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final initials = name != null && name!.isNotEmpty
        ? name!.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
