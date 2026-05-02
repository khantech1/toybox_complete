import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../home/main_scaffold.dart';

class ProposalSentScreen extends StatelessWidget {
  final String partnerName;
  const ProposalSentScreen({super.key, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScaffold()),
              (_) => false,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Animated success icon
            Container(
              width: 160,
              height: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    child: Container(
                      width: 56,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.card_giftcard, color: AppColors.primary, size: 30),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: Container(
                      width: 56,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.swap_horiz, color: AppColors.primary, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Request Sent!',
              style: AppTextStyles.display.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.body.copyWith(height: 1.6),
                children: [
                  const TextSpan(text: "Your exchange request has been sent to "),
                  TextSpan(
                    text: partnerName,
                    style: AppTextStyles.bodyMed,
                  ),
                  const TextSpan(
                      text: ". We'll notify you once they respond."),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Success pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Request successfully delivered',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            PrimaryButton(
              label: 'Back to Home',
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScaffold()),
                (_) => false,
              ),
              trailing:
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
