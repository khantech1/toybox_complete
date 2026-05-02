import 'package:flutter/material.dart';
import 'package:toybox/utils/shared_prefs.dart';
import '../../api/exchange_requests_api.dart';
import '../../api/api_client.dart';
import '../../models/exchange_request_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/status_badge.dart';
import 'request_detail_screen.dart';
import 'rate_member_sheet.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ExchangeRequestModel> _pending = [];
  List<ExchangeRequestModel> _completed = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ExchangeRequestsApi.getAll(status: 'pending'),
        ExchangeRequestsApi.getAll(status: 'completed'),
      ]);
      if (mounted) {
        setState(() {
          _pending = results[0];
          _completed = results[1];
        });
      }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () {},
        ),
        title: const Text('Requests'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: AppTextStyles.bodyMed,
          unselectedLabelStyle: AppTextStyles.bodySec,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _loading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidget2(message: _error!, onRetry: _loadAll)
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _PendingList(requests: _pending, onRefresh: _loadAll),
                _CompletedList(requests: _completed, onRefresh: _loadAll),
              ],
            ),
    );
  }
}

// ── Pending Tab ───────────────────────────────────────────────────────────────

class _PendingList extends StatelessWidget {
  final List<ExchangeRequestModel> requests;
  final VoidCallback onRefresh;

  const _PendingList({required this.requests, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyWidget(
        title: 'No pending requests',
        subtitle: 'When someone requests to exchange with you, it appears here',
        icon: Icons.swap_horiz_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) => _PendingTile(
          request: requests[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RequestDetailScreen(requestId: requests[i].requestId),
            ),
          ).then((_) => onRefresh()),
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final ExchangeRequestModel request;
  final VoidCallback onTap;

  const _PendingTile({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final requestedToy = request.requestedToys.firstOrNull?.toy;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: requestedToy?.primaryImageUrl,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            requestedToy?.toyName ?? 'Exchange Request',
                            style: AppTextStyles.bodyMed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (request.initiator != null)
                      Row(
                        children: [
                          Text('Requested by ', style: AppTextStyles.labelSec),
                          Text(
                            request.initiator!.name,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    if (request.initiator?.rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.star,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${request.initiator!.rating!.toStringAsFixed(1)}/10.0 rating',
                            style: AppTextStyles.labelSec,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderMed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                  ),
                  child: Text('Details', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Completed Tab ─────────────────────────────────────────────────────────────

class _CompletedList extends StatelessWidget {
  final List<ExchangeRequestModel> requests;
  final VoidCallback onRefresh;

  const _CompletedList({required this.requests, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyWidget(
        title: 'No completed exchanges yet',
        subtitle: 'Completed exchanges will appear here',
        icon: Icons.check_circle_outline,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) => _CompletedTile(
          request: requests[i],
          onRateMember: () => _showRateSheet(context, requests[i]),
        ),
      ),
    );
  }

  void _showRateSheet(
    BuildContext context,
    ExchangeRequestModel request,
  ) async {
    final currentUserId = await SharedPrefs.getUserId();

    final partner = request.initiatorUserId == currentUserId
        ? request.offeredToys.firstOrNull?.toy?.owner
        : request.initiator;

    if (partner == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateMemberSheet(
        requestId: request.requestId,
        revieweeUserId: partner.userId,
        partnerName: partner.name,
        partnerImageUrl: partner.profilePic,
      ),
    );
  }
}

class _CompletedTile extends StatelessWidget {
  final ExchangeRequestModel request;
  final VoidCallback onRateMember;

  const _CompletedTile({required this.request, required this.onRateMember});

  Future<int?> _getCurrentUserId() async {
    return await SharedPrefs.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getCurrentUserId(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data;

        final partner = request.initiatorUserId == currentUserId
            ? request.offeredToys.firstOrNull?.toy?.owner
            : request.initiator;

        final displayToy = request.initiatorUserId == currentUserId
            ? request.offeredToys.firstOrNull?.toy
            : request.requestedToys.firstOrNull?.toy;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AppNetworkImage(
                    imageUrl: displayToy?.primaryImageUrl,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayToy?.toyName ?? 'Exchange',
                                style: AppTextStyles.bodyMed,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: request.status),
                          ],
                        ),
                        if (partner != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Exchanged with ',
                                style: AppTextStyles.labelSec,
                              ),
                              Text(
                                partner.name,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Rate Member',
                onTap: onRateMember,
                height: 44,
              ),
            ],
          ),
        );
      },
    );
  }
}
