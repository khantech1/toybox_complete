import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/auth_api.dart';
import '../../api/profile_api.dart';
import '../../api/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/main_scaffold.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  File? _photo;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthApi.profileSetup(
        name:    _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      if (_photo != null) await ProfileApi.uploadProfilePic(_photo!);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Set Up Profile'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Step 2 of 2', style: AppTextStyles.labelSec),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo picker
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.border,
                        image: _photo != null
                            ? DecorationImage(
                                image: FileImage(_photo!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _photo == null
                          ? const Icon(Icons.person_rounded,
                              size: 48, color: AppColors.textMuted)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Add a photo', style: AppTextStyles.title),
              Text('Show us your smile!', style: AppTextStyles.bodySec),
              const SizedBox(height: 32),

              AppTextField(
                label: 'User Name',
                hint: 'Enter your name',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.textMuted, size: 18),
                validator: (v) => Validators.required(v, field: 'Name'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Address',
                hint: 'City, State',
                controller: _addressCtrl,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textMuted, size: 18),
                validator: (v) => Validators.required(v, field: 'Address'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Used to find toy exchanges near you.',
                    style: AppTextStyles.labelSec),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                  label: 'Save & Continue',
                  isLoading: _loading,
                  onTap: _save),
            ],
          ),
        ),
      ),
    );
  }
}
