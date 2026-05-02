import 'package:flutter/material.dart';
import '../models/toy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_network_image.dart';

class ToyCard extends StatelessWidget {
  final ToyModel toy;
  final VoidCallback? onTap;
  final VoidCallback? onRequestExchange;
  final bool isNew;

  const ToyCard({
    super.key,
    required this.toy,
    this.onTap,
    this.onRequestExchange,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AppNetworkImage(
                  imageUrl: toy.primaryImageUrl,
                  height: 180,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.newBadge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NEW',
                        style: AppTextStyles.micro.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: isNew ? 56 : 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          toy.toyName,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (toy.conditionStatus != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.star,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${toy.conditionStatus}/10',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (toy.owner != null)
                    Row(
                      children: [
                        Text('Listed by ', style: AppTextStyles.labelSec),
                        Text(
                          toy.owner!.name,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (toy.owner!.rating != null) ...[
                          Text(' • Rating: ', style: AppTextStyles.labelSec),
                          Text(
                            '${toy.owner!.rating}/10',
                            style: AppTextStyles.labelSec,
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('ESTIMATED VALUE:', style: AppTextStyles.microUpper),
                      const SizedBox(width: 6),
                      Text(
                        toy.value != null
                            ? 'Rs. ${toy.value!.toStringAsFixed(0)}'
                            : 'N/A',
                        style: AppTextStyles.title,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onRequestExchange,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Request Exchange',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
