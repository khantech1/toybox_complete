import 'package:flutter/material.dart';
import 'package:toybox/api/auth_api.dart';
import 'package:toybox/screens/auth/login_screen.dart';
import '../../api/profile_api.dart';
import '../../api/toys_api.dart';
import '../../api/api_client.dart';
import '../../models/user_model.dart';
import '../../models/toy_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/state_widgets.dart';
import '../toys/edit_toy_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  List<ToyModel> _toys = [];
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
      final results = await Future.wait([
        ProfileApi.getMe(),
        ToysApi.getMyToys(),
      ]);
      if (mounted) {
        setState(() {
          _user = results[0] as UserModel;
          _toys = results[1] as List<ToyModel>;
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
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () async {
              await AuthApi.logout();

              if (!context.mounted) return;

              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: _user == null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: _user!),
                    ),
                  ).then((_) => _load()),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _error != null
          ? ErrorWidget2(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildStats(),
                    _buildMyToys(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final user = _user!;
    return Container(
      color: AppColors.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          UserAvatar(imageUrl: user.profilePic, name: user.name, size: 88),
          const SizedBox(height: 14),
          Text(user.name, style: AppTextStyles.headline),
          const SizedBox(height: 4),
          if (user.address != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 2),
                Text(user.address!, style: AppTextStyles.bodySec),
              ],
            ),
          const SizedBox(height: 12),
          // Reliability badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Text(
              user.rating != null
                  ? '${user.rating!.toStringAsFixed(1)}/10 Reliability'
                  : 'New Member',
              style: AppTextStyles.label.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      color: AppColors.surfaceContainer,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatTile(value: '${_toys.length}', label: 'TOYS LISTED'),
          Container(width: 1, height: 40, color: AppColors.border),
          const _StatTile(value: '—', label: 'EXCHANGES'),
        ],
      ),
    );
  }

  Widget _buildMyToys() {
    return Container(
      color: AppColors.surfaceContainer,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My Toys', style: AppTextStyles.headline),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_toys.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No toys listed yet. Add your first toy!',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _toys.length,
              itemBuilder: (_, i) => _ToyGridItem(
                toy: _toys[i],
                onEdit: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditToyScreen(toy: _toys[i]),
                      ),
                    ).then((r) {
                      if (r == true || r == 'deleted') _load();
                    }),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.display.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.microUpper),
        ],
      ),
    );
  }
}

class _ToyGridItem extends StatelessWidget {
  final ToyModel toy;
  final VoidCallback onEdit;
  const _ToyGridItem({required this.toy, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AppNetworkImage(
            imageUrl: toy.primaryImageUrl,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Edit button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        // Name overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              toy.toyName,
              style: AppTextStyles.micro.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
