import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../api/api_client.dart';
import '../../api/categories_api.dart';
import '../../api/profile_api.dart';
import '../../api/toys_api.dart';
import '../../models/category_model.dart';
import '../../models/contact_model.dart';
import '../../models/toy_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_widgets.dart';

class EditToyScreen extends StatefulWidget {
  final ToyModel toy;

  const EditToyScreen({super.key, required this.toy});

  @override
  State<EditToyScreen> createState() => _EditToyScreenState();
}

class _EditToyScreenState extends State<EditToyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _worthCtrl;

  List<CategoryModel> _categories = [];
  List<ContactModel> _contacts = [];
  final List<int> _selectedContactIds = [];
  List<File> _newImages = [];

  CategoryModel? _selectedCat;
  CategoryModel? _desiredCat;

  late int _condition;

  bool _visibleToAll = true;
  bool _loading = false;
  bool _initLoading = true;

  @override
  void initState() {
    super.initState();

    final t = widget.toy;

    _nameCtrl = TextEditingController(text: t.toyName);
    _descCtrl = TextEditingController(text: t.toyDescription ?? '');
    _worthCtrl = TextEditingController(
      text: t.value != null ? t.value!.toStringAsFixed(2) : '',
    );

    _condition = t.conditionStatus ?? 5;

    _loadInit();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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

      final cats = results[0] as List<CategoryModel>;
      final contacts = results[1] as List<ContactModel>;

      if (!mounted) return;

      setState(() {
        _categories = cats;
        _contacts = contacts;

        if (widget.toy.categoryId != null && cats.isNotEmpty) {
          _selectedCat = cats.firstWhere(
            (c) => c.categoryId == widget.toy.categoryId,
            orElse: () => cats.first,
          );
        }

        if (widget.toy.desiredCategoryId != null && cats.isNotEmpty) {
          _desiredCat = cats.firstWhere(
            (c) => c.categoryId == widget.toy.desiredCategoryId,
            orElse: () => cats.first,
          );
        }

        _visibleToAll = true;
      });
    } catch (_) {
      // keep screen usable even if loading contacts/categories fails
    }

    if (mounted) {
      setState(() => _initLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ToysApi.update(
        toyId: widget.toy.toyId,
        toyName: _nameCtrl.text.trim(),
        toyDescription: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        categoryId: _selectedCat?.categoryId,
        desiredCategoryId: _desiredCat?.categoryId,
        conditionStatus: _condition,
        value: double.tryParse(_worthCtrl.text.trim()),
        visibleToAll: _visibleToAll,
        visibleToUserIds: _visibleToAll ? null : _selectedContactIds,
      );

      if (_newImages.isNotEmpty) {
        await ToysApi.uploadImages(widget.toy.toyId, _newImages);
      }

      if (!mounted) return;

      AppSnackbar.success(context, 'Toy updated successfully!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteToy() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Toy'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ToysApi.delete(widget.toy.toyId);
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _pickImages() async {
    final totalImages = widget.toy.images.length + _newImages.length;

    if (totalImages >= 5) {
      AppSnackbar.error(context, 'Maximum 5 images allowed');
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);

    if (picked.isNotEmpty) {
      final remaining = 5 - totalImages;

      setState(() {
        _newImages.addAll(picked.take(remaining).map((e) => File(e.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Edit Toy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteToy,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...widget.toy.images.map(
                      (img) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 150,
                        child: AppNetworkImage(
                          imageUrl: img.imageUrl,
                          height: 180,
                          width: 150,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    ..._newImages.map(
                      (file) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    if ((widget.toy.images.length + _newImages.length) < 5)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 150,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 38,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Toy Name',
                hint: 'Enter toy name',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Toy name'),
              ),

              const SizedBox(height: 16),

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
                      onChanged: (v) {
                        setState(() {
                          _visibleToAll = v;
                          if (v) _selectedContactIds.clear();
                        });
                      },
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
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _selectedContactIds.remove(c.contactId);
                                    } else {
                                      _selectedContactIds.add(c.contactId);
                                    }
                                  });
                                },
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

              Text('Category', style: AppTextStyles.microUpper),
              const SizedBox(height: 6),

              DropdownButtonFormField<CategoryModel>(
                initialValue: _selectedCat,
                decoration: const InputDecoration(),
                hint: Text('Select Category', style: AppTextStyles.bodySec),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.categoryName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCat = v),
              ),

              const SizedBox(height: 16),

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
                label: 'Description',
                hint: 'Tell us more about the toy...',
                controller: _descCtrl,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

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

              Text('Open to Exchange For...', style: AppTextStyles.microUpper),
              const SizedBox(height: 6),

              DropdownButtonFormField<CategoryModel>(
                initialValue: _desiredCat,
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
                onChanged: (v) => setState(() => _desiredCat = v),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Update Listing',
                isLoading: _loading,
                onTap: _submit,
                leading: const Icon(
                  Icons.check_circle_outline,
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
