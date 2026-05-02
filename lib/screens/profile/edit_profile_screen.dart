import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/profile_api.dart';
import '../../api/api_client.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey     = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  File? _newPhoto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: widget.user.name);
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _newPhoto = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ProfileApi.update(
        name:    _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      if (_newPhoto != null) {
        await ProfileApi.uploadProfilePic(_newPhoto!);
      }
      if (!mounted) return;
      AppSnackbar.success(context, 'Profile updated successfully!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Photo picker ────────────────────────────────────────────
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    _newPhoto != null
                        ? ClipOval(
                            child: Image.file(_newPhoto!,
                                width: 96, height: 96, fit: BoxFit.cover))
                        : UserAvatar(
                            imageUrl: user.profilePic,
                            name:     user.name,
                            size:     96),
                    Positioned(
                      bottom: 0,
                      right:  0,
                      child: Container(
                        width:  30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickPhoto,
                child: Text(
                  'CHANGE PHOTO',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),

              // ── Name field ──────────────────────────────────────────────
              AppTextField(
                label: 'FULL NAME',
                hint: 'Your full name',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Name'),
              ),
              const SizedBox(height: 16),

              // ── Address field ───────────────────────────────────────────
              AppTextField(
                label: 'ADDRESS / LOCATION',
                hint: 'City, State',
                controller: _addressCtrl,
                textInputAction: TextInputAction.done,
                suffixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
              const SizedBox(height: 16),

              // ── Reliability score (read-only) ───────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('RELIABILITY SCORE',
                    style: AppTextStyles.microUpper),
              ),
              const SizedBox(height: 8),
              SectionCard(
                color: AppColors.primaryLight,
                child: Row(
                  children: [
                    Container(
                      width:  40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_user,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.rating != null
                                ? '${user.rating!.toStringAsFixed(1)}/10'
                                : 'N/A',
                            style: AppTextStyles.title
                                .copyWith(color: AppColors.primary),
                          ),
                          Text(
                            user.rating != null && user.rating! >= 9
                                ? 'EXCELLENT STATUS'
                                : 'GOOD STATUS',
                            style: AppTextStyles.microUpper
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.lock_outline,
                        color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your reliability score is based on your exchange history and cannot be edited manually.',
                  style: AppTextStyles.labelSec
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),

              // ── Identity verification card ──────────────────────────────
              SectionCard(
                child: Row(
                  children: [
                    Container(
                      width:  36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline,
                          color: AppColors.textSecondary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Identity Verification',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          SizedBox(height: 2),
                          Text(
                            'Verified identities help build trust within the community. Your badges will appear on your public profile.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                  label: 'Save Changes',
                  isLoading: _loading,
                  onTap: _save),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
