import 'package:flutter/material.dart';
import '../../api/toys_api.dart';
import '../../api/categories_api.dart';
import '../../api/api_client.dart';
import '../../models/toy_model.dart';
import '../../models/category_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/toy_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/state_widgets.dart';
import '../toys/toy_detail_screen.dart';
import '../exchange/exchange_proposal_screen.dart';

class ToyCatalogScreen extends StatefulWidget {
  const ToyCatalogScreen({super.key});

  @override
  State<ToyCatalogScreen> createState() => _ToyCatalogScreenState();
}

class _ToyCatalogScreenState extends State<ToyCatalogScreen> {
  final _searchCtrl = TextEditingController();
  List<ToyModel> _toys = [];
  List<CategoryModel> _categories = [];
  int? _activeCategoryId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ToysApi.getAll(
          categoryId: _activeCategoryId,
          search: _searchCtrl.text.trim(),
        ),
        CategoriesApi.getAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _toys = results[0] as List<ToyModel>;
        _categories = results[1] as List<CategoryModel>;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCategoryChanged(int? id) {
    setState(() => _activeCategoryId = id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Toy Catalog',
          style: AppTextStyles.headline.copyWith(color: AppColors.primary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search for toys...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _loadData(),
                ),
              ),
            ),
            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    CategoryChip(
                      label: 'All Toys',
                      isActive: _activeCategoryId == null,
                      onTap: () => _onCategoryChanged(null),
                    ),
                    const SizedBox(width: 8),
                    ..._categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: c.categoryName,
                          isActive: _activeCategoryId == c.categoryId,
                          onTap: () => _onCategoryChanged(c.categoryId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            if (_loading)
              const SliverFillRemaining(child: LoadingWidget())
            else if (_error != null)
              SliverFillRemaining(
                child: ErrorWidget2(message: _error!, onRetry: _loadData),
              )
            else if (_toys.isEmpty)
              const SliverFillRemaining(
                child: EmptyWidget(
                  title: 'No toys found',
                  subtitle: 'Try a different category or search term',
                  icon: Icons.toys_rounded,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ToyCard(
                        toy: _toys[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ToyDetailScreen(toyId: _toys[i].toyId),
                          ),
                        ),
                        onRequestExchange: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ExchangeProposalScreen(requestedToy: _toys[i]),
                          ),
                        ),
                      ),
                    ),
                    childCount: _toys.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
