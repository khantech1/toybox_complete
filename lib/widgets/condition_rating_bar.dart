import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ConditionRatingBar extends StatelessWidget {
  final String label;
  final double value; // 0 to 10
  final double max;

  const ConditionRatingBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(label, style: AppTextStyles.microUpper)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(1),
                    style: AppTextStyles.title
                        .copyWith(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: '/$max',
                    style: AppTextStyles.bodySec,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (_, constraints) {
            return Stack(
              children: [
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.borderMed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * (value / max),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
