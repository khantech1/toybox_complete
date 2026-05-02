import 'package:flutter/material.dart';
import '../../api/toys_api.dart';
import '../../api/api_client.dart';
import '../../models/toy_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/condition_rating_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_widgets.dart';
import '../exchange/exchange_proposal_screen.dart';

class ToyDetailScreen extends StatefulWidget {
  final int toyId;
  const ToyDetailScreen({super.key, required this.toyId});

  @override
  State<ToyDetailScreen> createState() => _ToyDetailScreenState();
}

class _ToyDetailScreenState extends State<ToyDetailScreen> {
  ToyModel? _toy;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final toy = await ToysApi.getById(widget.toyId);
      if (mounted) setState(() => _toy = toy);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidget2(message: _error!, onRetry: _load)
          : _toy == null
          ? const SizedBox()
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final toy = _toy!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                SizedBox(
                  height: 300,
                  child: toy.images.isEmpty
                      ? const AppNetworkImage(
                          imageUrl: null,
                          height: 300,
                          width: double.infinity,
                          fallbackIcon: Icons.toys_rounded,
                        )
                      : PageView.builder(
                          itemCount: toy.images.length,
                          itemBuilder: (context, index) {
                            return AppNetworkImage(
                              imageUrl: toy.images[index].imageUrl,
                              height: 300,
                              width: double.infinity,
                              fallbackIcon: Icons.toys_rounded,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + value
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    toy.toyName,
                                    style: AppTextStyles.headline,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      toy.value != null
                                          ? 'Rs. ${toy.value!.toStringAsFixed(0)}'
                                          : 'N/A',
                                      style: AppTextStyles.headline.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'EST. VALUE',
                                      style: AppTextStyles.microUpper,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (toy.owner != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    toy.owner!.name,
                                    style: AppTextStyles.bodySec,
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Tags
                            Wrap(
                              spacing: 8,
                              children: [
                                if (toy.category != null)
                                  _tag(
                                    Icons.category_outlined,
                                    toy.category!.categoryName,
                                  ),
                              ],
                            ),
                            // Expected exchange
                            if (toy.desiredCategory != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.swap_horiz,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Expected Exchange',
                                    style: AppTextStyles.bodyMed,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                toy.desiredCategory!.categoryName,
                                style: AppTextStyles.bodySec,
                              ),
                            ],
                            // About
                            if (toy.toyDescription != null) ...[
                              const SizedBox(height: 16),
                              Text('About', style: AppTextStyles.bodyMed),
                              const SizedBox(height: 6),
                              Text(
                                toy.toyDescription!,
                                style: AppTextStyles.bodySec,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Trust & Quality
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Trust & Quality',
                                  style: AppTextStyles.bodyMed,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ConditionRatingBar(
                              label: 'TOY CONDITION RATING',
                              value: (toy.conditionStatus ?? 0).toDouble(),
                            ),
                            const SizedBox(height: 16),
                            ConditionRatingBar(
                              label: 'MEMBER RELIABILITY',
                              value: (toy.owner?.rating ?? 0).toDouble(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // CTA
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceContainer,
          child: PrimaryButton(
            label: 'Request Exchange',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExchangeProposalScreen(requestedToy: toy),
              ),
            ),
            trailing: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
