import 'package:flutter/material.dart';
import '../../api/exchange_requests_api.dart';
import '../../api/api_client.dart';
import '../../models/exchange_request_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_widgets.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  ExchangeRequestModel? _request;
  bool _loading = true;
  bool _actionLoading = false;
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
      final req = await ExchangeRequestsApi.getById(widget.requestId);
      if (mounted) setState(() => _request = req);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept() async {
    setState(() => _actionLoading = true);
    try {
      await ExchangeRequestsApi.accept(widget.requestId);
      if (!mounted) return;
      AppSnackbar.success(context, 'Request accepted!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _decline() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Request'),
        content: const Text('Are you sure you want to decline this exchange?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Decline',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _actionLoading = true);
    try {
      await ExchangeRequestsApi.decline(widget.requestId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Request Details'),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: _loading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidget2(message: _error!, onRetry: _load)
          : _request == null
          ? const SizedBox()
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final req = _request!;
    final partnerToys = req.offeredToys;
    final myToy = req.requestedToys.firstOrNull?.toy;
    final partner = req.initiator;
    final partnerOffValue = partnerToys.fold<double>(
      0,
      (s, t) => s + (t.toy?.value?.toDouble() ?? 0),
    );
    final myOfferValue = req.requestedToys.fold<double>(
      0,
      (s, t) => s + (t.toy?.value?.toDouble() ?? 0),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Partner offered toys
                Text('PARTNER OFFERED TOYS', style: AppTextStyles.microUpper),
                const SizedBox(height: 8),
                ...partnerToys.map((t) => _ToyRow(toy: t.toy)),

                const SizedBox(height: 20),

                // Your offer
                Text('YOUR OFFER', style: AppTextStyles.microUpper),
                const SizedBox(height: 8),
                _ToyRow(toy: myToy, showChevron: true),

                const SizedBox(height: 20),

                // Partner info
                if (partner != null) ...[
                  Text('PARTNER', style: AppTextStyles.microUpper),
                  const SizedBox(height: 8),
                  SectionCard(
                    child: Row(
                      children: [
                        UserAvatar(
                          imageUrl: partner.profilePic,
                          name: partner.name,
                          size: 48,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(partner.name, style: AppTextStyles.title),
                              if (partner.address != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      partner.address!,
                                      style: AppTextStyles.labelSec,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (partner.rating != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.star,
                                    size: 14,
                                  ),
                                  Text(
                                    partner.rating!.toStringAsFixed(1),
                                    style: AppTextStyles.title.copyWith(
                                      color: AppColors.star,
                                    ),
                                  ),
                                ],
                              ),
                              Text('RATING', style: AppTextStyles.microUpper),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Value summary
                SectionCard(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      _ValueRow(
                        label: 'Total Request Value',
                        value: partnerOffValue,
                      ),
                      const SizedBox(height: 8),
                      _ValueRow(
                        label: 'Total Offer Value',
                        value: myOfferValue,
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Accept / Decline buttons (only if pending)
        if (req.isPending)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceContainer,
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Accept Request',
                  isLoading: _actionLoading,
                  onTap: _accept,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _actionLoading ? null : _decline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderMed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cancel Request',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ToyRow extends StatelessWidget {
  final dynamic toy;
  final bool showChevron;
  const _ToyRow({this.toy, this.showChevron = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          AppNetworkImage(
            imageUrl: toy?.primaryImageUrl,
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(toy?.toyName ?? 'Toy', style: AppTextStyles.bodyMed),
                if (toy?.conditionStatus != null)
                  Text(
                    'Condition: ${toy!.conditionStatus}/10',
                    style: AppTextStyles.labelSec,
                  ),
                if (toy?.value != null)
                  Text(
                    'Est. Value: Rs:${toy!.value!.toStringAsFixed(0)}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (showChevron)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final double value;
  final bool highlight;
  const _ValueRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySec),
        const Spacer(),
        Text(
          'Rs:${value.toStringAsFixed(2)}',
          style: AppTextStyles.title.copyWith(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
