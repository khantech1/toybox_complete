import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.micro.copyWith(color: style.$1),
      ),
    );
  }

  (Color, Color) _styleFor(String s) {
    switch (s) {
      case 'completed':
        return (AppColors.success, AppColors.successLight);
      case 'pending':
        return (AppColors.warning, AppColors.warningLight);
      case 'accepted':
        return (AppColors.primary, AppColors.primaryLight);
      case 'declined':
        return (AppColors.error, AppColors.errorLight);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }
}
