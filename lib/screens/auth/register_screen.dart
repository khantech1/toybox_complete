import 'package:flutter/material.dart';
import '../../api/auth_api.dart';
import '../../api/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'profile_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthApi.register(
        email:    _emailCtrl.text.trim(),
        phoneNo:  _phoneCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account'),
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
                    value: 0.5,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Step 1 of 2', style: AppTextStyles.labelSec),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join ToyBox', style: AppTextStyles.headline),
              const SizedBox(height: 6),
              Text('Start exchanging and donating toys today.',
                  style: AppTextStyles.bodySec),
              const SizedBox(height: 28),

              AppTextField(
                label: 'Email',
                hint: 'example@email.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.mail_outline,
                    color: AppColors.textMuted, size: 18),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Phone Number',
                hint: '(555) 000-0000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppColors.textMuted, size: 18),
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passCtrl,
                obscureText: true,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textMuted, size: 18),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Confirm Password',
                hint: '••••••••',
                controller: _confirmCtrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textMuted, size: 18),
                validator: (v) =>
                    Validators.confirmPassword(v, _passCtrl.text),
              ),
              const SizedBox(height: 16),

              Text(
                'By clicking Continue, you agree to our Terms and Privacy Policy.',
                style: AppTextStyles.labelSec,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Continue',
                isLoading: _loading,
                onTap: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
