import 'package:flutter/material.dart';
import '../../api/reviews_api.dart';
import '../../api/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';

class RateMemberSheet extends StatefulWidget {
  final int requestId;
  final int revieweeUserId;
  final String partnerName;
  final String? partnerImageUrl;

  const RateMemberSheet({
    super.key,
    required this.requestId,
    required this.revieweeUserId,
    required this.partnerName,
    this.partnerImageUrl,
  });

  @override
  State<RateMemberSheet> createState() => _RateMemberSheetState();
}

class _RateMemberSheetState extends State<RateMemberSheet> {
  int? _selected;
  bool _loading = false;

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      await ReviewsApi.create(
        requestId:       widget.requestId,
        revieweeUserId:  widget.revieweeUserId,
        ratingScore:     _selected!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.success(context, 'Review submitted successfully!');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Avatar
          UserAvatar(
            imageUrl: widget.partnerImageUrl,
            name:     widget.partnerName,
            size:     72,
          ),
          const SizedBox(height: 12),
          Text('Exchange with', style: AppTextStyles.bodySec),
          const SizedBox(height: 4),
          Text(widget.partnerName, style: AppTextStyles.headline),
          const SizedBox(height: 20),
          Text('Rate your experience', style: AppTextStyles.title),
          const SizedBox(height: 16),

          // 1–10 rating grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(10, (i) {
              final val        = i + 1;
              final isSelected = _selected == val;
              return GestureDetector(
                onTap: () => setState(() => _selected = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.borderMed),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: AppTextStyles.title.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Submit Review',
            isLoading: _loading,
            onTap: _selected != null ? _submit : null,
            leading: const Icon(Icons.send_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderMed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancel',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
