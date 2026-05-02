import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/toys_api.dart';
import '../../api/categories_api.dart';
import '../../api/profile_api.dart';
import '../../api/api_client.dart';
import '../../models/category_model.dart';
import '../../models/contact_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_widgets.dart';

class AddToyScreen extends StatefulWidget {
  const AddToyScreen({super.key});

  @override
  State<AddToyScreen> createState() => _AddToyScreenState();
}

class _AddToyScreenState extends State<AddToyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _worthCtrl = TextEditingController();

  List<File> _images = [];
  List<CategoryModel> _categories = [];
  List<ContactModel> _contacts = [];
  List<int> _selectedContactIds = [];

  CategoryModel? _selectedCategory;
  CategoryModel? _desiredCategory;
  int _condition = 5;
  bool _visibleToAll = true;
  bool _loading = false;
  bool _initLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInit();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _worthCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInit() async {
    try {
      final results = await Future.wait([
        CategoriesApi.getAll(),
        ProfileApi.getContacts(),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _contacts = results[1] as List<ContactModel>;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _initLoading = false);
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      final remaining = 5 - _images.length;
      setState(() {
        _images.addAll(picked.take(remaining).map((e) => File(e.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      AppSnackbar.error(context, 'Please add at least one photo');
      return;
    }
    setState(() => _loading = true);
    try {
      final toy = await ToysApi.create(
        toyName: _nameCtrl.text.trim(),
        toyDescription: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        categoryId: _selectedCategory?.categoryId,
        desiredCategoryId: _desiredCategory?.categoryId,
        conditionStatus: _condition,
        value: double.tryParse(_worthCtrl.text.trim()),
        visibleToAll: _visibleToAll,
        visibleToUserIds: _visibleToAll ? null : _selectedContactIds,
      );
      await ToysApi.uploadImages(toy.toyId, _images);
      if (!mounted) return;
      AppSnackbar.success(context, 'Toy posted successfully!');
      _resetForm();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _ageCtrl.clear();
    _descCtrl.clear();
    _worthCtrl.clear();
    setState(() {
      _images = [];
      _selectedCategory = null;
      _desiredCategory = null;
      _condition = 5;
      _visibleToAll = true;
      _selectedContactIds = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Add Toy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo upload ────────────────────────────────────────────
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: _images.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Upload Photos', style: AppTextStyles.bodyMed),
                            Text(
                              'Add up to 5 clear images',
                              style: AppTextStyles.labelSec,
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              itemCount: _images.length,
                              itemBuilder: (_, i) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_images[i]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (_images.length < 5)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Toy Name ────────────────────────────────────────────────
              AppTextField(
                label: 'Toy Name',
                hint: 'e.g. Classic Wooden Train Set',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Toy name'),
              ),
              const SizedBox(height: 16),

              // ── Visible To ──────────────────────────────────────────────
              Text('Visible To', style: AppTextStyles.microUpper),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMed),
                ),
                child: Row(
                  children: [
                    Text('All Contacts', style: AppTextStyles.body),
                    const Spacer(),
                    Switch.adaptive(
                      value: _visibleToAll,
                      onChanged: (v) => setState(() => _visibleToAll = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              if (!_visibleToAll) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Specific Contacts',
                        style: AppTextStyles.bodyMed.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_contacts.isEmpty)
                        Text('No contacts found', style: AppTextStyles.labelSec)
                      else
                        SizedBox(
                          height: 65,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _contacts.length,
                            itemBuilder: (_, i) {
                              final c = _contacts[i];
                              final selected = _selectedContactIds.contains(
                                c.contactId,
                              );
                              return GestureDetector(
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selectedContactIds.remove(c.contactId);
                                  } else {
                                    _selectedContactIds.add(c.contactId);
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          UserAvatar(
                                            imageUrl: c.contactUser?.profilePic,
                                            name: c.contactUser?.name,
                                            size: 40,
                                          ),
                                          if (selected)
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 14,
                                                height: 14,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 9,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.contactUser?.name.split(' ').first ??
                                            'User',
                                        style: AppTextStyles.micro,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Category ────────────────────────────────────────────────
              Text('Category', style: AppTextStyles.microUpper),
              const SizedBox(height: 6),
              DropdownButtonFormField<CategoryModel>(
                initialValue: _selectedCategory,
                hint: Text('Select Category', style: AppTextStyles.bodySec),
                decoration: const InputDecoration(),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.categoryName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 16),

              // ── Condition ───────────────────────────────────────────────
              Text('Condition', style: AppTextStyles.microUpper),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(10, (i) {
                  final val = i + 1;
                  final active = _condition == val;
                  return GestureDetector(
                    onTap: () => setState(() => _condition = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.primary
                            : AppColors.surfaceContainer,
                        border: active
                            ? null
                            : Border.all(color: AppColors.borderMed),
                      ),
                      child: Center(
                        child: Text(
                          '$val',
                          style: AppTextStyles.label.copyWith(
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Target Age Group',
                hint: 'e.g. 3–5 years',
                controller: _ageCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Description',
                hint: 'Tell us more about the toy...',
                controller: _descCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // ── Estimated Worth ─────────────────────────────────────────
              AppTextField(
                label: 'Estimated Worth',
                hint: '0.00',
                controller: _worthCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Rs.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) => Validators.positiveNumber(v, field: 'Worth'),
              ),
              const SizedBox(height: 16),

              // ── Open to Exchange For ────────────────────────────────────
              Text('Open to Exchange For...', style: AppTextStyles.microUpper),
              const SizedBox(height: 6),
              DropdownButtonFormField<CategoryModel>(
                initialValue: _desiredCategory,
                hint: Text(
                  'Select Preferred Category',
                  style: AppTextStyles.bodySec,
                ),
                decoration: const InputDecoration(),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.categoryName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _desiredCategory = v),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Post Toy',
                isLoading: _loading,
                onTap: _submit,
                trailing: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
