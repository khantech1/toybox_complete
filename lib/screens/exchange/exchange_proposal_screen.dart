import 'package:flutter/material.dart';
import '../../api/toys_api.dart';
import '../../api/exchange_requests_api.dart';
import '../../api/api_client.dart';
import '../../models/toy_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_widgets.dart';
import 'proposal_sent_screen.dart';

class ExchangeProposalScreen extends StatefulWidget {
  final ToyModel requestedToy;
  const ExchangeProposalScreen({super.key, required this.requestedToy});

  @override
  State<ExchangeProposalScreen> createState() => _ExchangeProposalScreenState();
}

class _ExchangeProposalScreenState extends State<ExchangeProposalScreen> {
  List<ToyModel> _myToys = [];
  ToyModel? _selected;
  final _msgCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyToys();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyToys() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final toys = await ToysApi.getMyToys();
      if (mounted) setState(() => _myToys = toys);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selected == null) {
      AppSnackbar.error(context, 'Please select a toy to offer');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ExchangeRequestsApi.create(
        requestedToyId: widget.requestedToy.toyId,
        offeredToyId: _selected!.toyId,
        message: _msgCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProposalSentScreen(
            partnerName: widget.requestedToy.owner?.name ?? 'the owner',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.requestedToy;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Exchange Proposal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidget2(message: _error!, onRetry: _loadMyToys)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── You are requesting ──────────────────────
                        Text(
                          'YOU ARE REQUESTING',
                          style: AppTextStyles.microUpper.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SectionCard(
                          child: Row(
                            children: [
                              AppNetworkImage(
                                imageUrl: req.primaryImageUrl,
                                width: 64,
                                height: 64,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.toyName,
                                      style: AppTextStyles.title,
                                    ),
                                    if (req.value != null)
                                      Text(
                                        'Est. Value: Rs${req.value!.toStringAsFixed(0)}',
                                        style: AppTextStyles.bodySec,
                                      ),
                                    if (req.conditionStatus != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Condition: ${req.conditionStatus}/10',
                                              style: AppTextStyles.micro
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Select your offer ───────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Select your offer',
                                style: AppTextStyles.title,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_myToys.length} Available',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose one of your items to trade',
                          style: AppTextStyles.bodySec,
                        ),
                        const SizedBox(height: 12),

                        if (_myToys.isEmpty)
                          const EmptyWidget(
                            title: 'No toys to offer',
                            subtitle:
                                'Add a toy first before making an exchange',
                            icon: Icons.toys_rounded,
                          )
                        else
                          ..._myToys.map(
                            (t) => _ToyOfferTile(
                              toy: t,
                              selected: _selected?.toyId == t.toyId,
                              onTap: () => setState(() => _selected = t),
                            ),
                          ),

                        // ── List a new toy button ───────────────────
                        // Container(
                        //   margin: const EdgeInsets.only(top: 8),
                        //   padding: const EdgeInsets.all(14),
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: AppColors.borderMed),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       const Icon(
                        //         Icons.add_circle_outline,
                        //         color: AppColors.textSecondary,
                        //         size: 18,
                        //       ),
                        //       const SizedBox(width: 8),
                        //       Text(
                        //         'List a new toy',
                        //         style: AppTextStyles.bodyMed.copyWith(
                        //           color: AppColors.textSecondary,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 16),

                        // ── Optional message ────────────────────────
                        TextField(
                          controller: _msgCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Add a friendly message (optional)...',
                            hintStyle: AppTextStyles.bodySec,
                            alignLabelWithHint: true,
                            suffixIcon: const Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Total value ─────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Total Estimated Value',
                                style: AppTextStyles.bodySec,
                              ),
                              const Spacer(),
                              Text(
                                _selected?.value != null
                                    ? 'Rs:${_selected!.value!.toStringAsFixed(0)}'
                                    : 'Rs:0',
                                style: AppTextStyles.title,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom CTA ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surfaceContainer,
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: 'Request Exchange',
                        isLoading: _submitting,
                        onTap: _submit,
                        trailing: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'BOTH PARTIES MUST CONFIRM THE TRADE',
                        style: AppTextStyles.microUpper,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Offer tile ────────────────────────────────────────────────────────────────

class _ToyOfferTile extends StatelessWidget {
  final ToyModel toy;
  final bool selected;
  final VoidCallback onTap;
  const _ToyOfferTile({
    required this.toy,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderMed,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: toy.primaryImageUrl,
              width: 56,
              height: 56,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(toy.toyName, style: AppTextStyles.bodyMed),
                  if (toy.conditionStatus != null)
                    Text(
                      _conditionLabel(toy.conditionStatus!),
                      style: AppTextStyles.labelSec,
                    ),
                  if (toy.value != null)
                    Text(
                      'Est. Value: Rs:${toy.value!.toStringAsFixed(0)}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            Radio<int>(
              value: toy.toyId,
              groupValue: selected ? toy.toyId : -1,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _conditionLabel(int c) {
    if (c >= 9) return 'Condition: Like New';
    if (c >= 7) return 'Condition: Good';
    if (c >= 5) return 'Condition: Fair';
    return 'Condition: Worn';
  }
}
