import 'dart:io';
import 'dart:ui';

import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_bloc.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_event.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/models/product_model.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  late List<String> _existingImages;
  List<Category> _categories = [];
  Category? _selectedCategory;
  final List<XFile> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  late List<String> _sizes;
  late List<String> _colors;

  bool _isSubmitting = false;
  bool _hasChanges = false;

  // Quick-pick options shown in the variant bottom sheet
  static const _quickSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '128GB',
    '256GB',
    '512GB'
  ];
  static const _quickColors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Gold',
    'Silver',
    'Grey'
  ];

  // Page entry animation — slides the form up from below on open
  late AnimationController _entryController;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();

    // Trigger categories fetch on screen load
    context.read<AdminCategoryBloc>().add(FetchCategoriesEvent());

    final p = widget.product;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toString());

    // Use stock from first variant, or default to 10 if no variants exist
    final firstStock = p.variants.isNotEmpty ? p.variants.first.stock : 10;
    _stockController = TextEditingController(text: firstStock.toString());

    _existingImages = List.from(p.images);
    _sizes = p.variants.map((v) => v.size).toSet().toList();
    _colors = p.variants.map((v) => v.color).toSet().toList();
    if (_sizes.isEmpty) _sizes = ['Default'];
    if (_colors.isEmpty) _colors = ['Default'];

    // Mark _hasChanges true whenever any text field is edited
    for (final ctrl in [
      _titleController,
      _descriptionController,
      _priceController,
      _stockController,
    ]) {
      ctrl.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ─── Image helpers ────────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final total = _existingImages.length + _newImages.length;
    if (total >= 5) {
      showAppSnackBar(context, 'Max 5 images allowed', isError: true);
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 82);
      if (picked.isEmpty) return;
      setState(() {
        _newImages.addAll(picked.take(5 - total));
        _hasChanges = true;
      });
    } catch (_) {
      showAppSnackBar(context, 'Could not pick images', isError: true);
    }
  }

  Future<void> _pickFromCamera() async {
    final total = _existingImages.length + _newImages.length;
    if (total >= 5) {
      showAppSnackBar(context, 'Max 5 images allowed', isError: true);
      return;
    }
    try {
      final picked =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 82);
      if (picked == null) return;
      setState(() {
        _newImages.add(picked);
        _hasChanges = true;
      });
    } catch (_) {
      showAppSnackBar(context, 'Could not open camera', isError: true);
    }
  }

  // Confirms before removing an existing image to prevent accidents
  void _removeExistingImage(String url) {
    showAppDialog(
      context,
      title: 'Remove Image?',
      message: 'This image will be removed when you save.',
      confirmLabel: 'Remove',
      isDestructive: true,
      icon: Icons.image_not_supported_outlined,
      onConfirm: () => setState(() {
        _existingImages.remove(url);
        _hasChanges = true;
      }),
    );
  }

  // ─── Variant helpers ──────────────────────────────────────────────────────────

  // Bottom sheet for adding sizes or colors with quick-pick chips + custom input
  void _showAddVariantSheet({
    required String label,
    required List<String> quickOptions,
    required List<String> current,
    required void Function(String) onAdd,
    required bool isDark,
  }) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color(0xFF0A0E1A),
                          Color(0xFF0D1F3C),
                          Color(0xFF0A0E1A),
                        ]
                      : [
                          Color.fromARGB(255, 255, 255, 255), // pure white
                          Color.fromARGB(
                              255, 255, 255, 255), // soft bluish grey
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: AppColors.neonCyan.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sheet drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Add $label',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick-pick chip row — only shows options not already added
                  if (quickOptions
                      .where((o) => !current.contains(o))
                      .isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickOptions
                          .where((o) => !current.contains(o))
                          .map((o) => GestureDetector(
                                onTap: () {
                                  onAdd(o);
                                  Navigator.pop(ctx);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonCyan.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          AppColors.neonCyan.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    o,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08)),
                  const SizedBox(height: 12),
                  // Custom text input for non-preset values
                  Row(
                    children: [
                      Expanded(
                        child: _GlassInput(
                          controller: ctrl,
                          hint: 'Custom $label...',
                          autofocus: true,
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              onAdd(v.trim());
                              Navigator.pop(ctx);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (ctrl.text.trim().isNotEmpty) {
                            onAdd(ctrl.text.trim());
                            Navigator.pop(ctx);
                          }
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.neonCyan,
                                AppColors.neonPurple
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withOpacity(0.35),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final totalImages = _existingImages.length + _newImages.length;
    if (totalImages == 0) {
      showAppSnackBar(context, 'At least 1 image required', isError: true);
      return;
    }
    if (_selectedCategory == null) {
      showAppSnackBar(context, 'Please select a category', isError: true);
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 10;
    final sizes = _sizes.isEmpty ? ['Default'] : _sizes;
    final colors = _colors.isEmpty ? ['Default'] : _colors;

    // Build a flat variants list from all size × color combinations
    final variants = <Map<String, dynamic>>[
      for (final s in sizes)
        for (final c in colors) {'size': s, 'color': c, 'stock': stock},
    ];

    context.read<AdminBloc>().add(
          AdminProductUpdateRequested(
            productId: widget.product.id,
            productData: {
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim(),
              'price': price,
              'categoryId': _selectedCategory!.id,
              'variants': variants,
            },
            existingImageUrls:
                _existingImages.isNotEmpty ? _existingImages : null,
            newImages: _newImages.isNotEmpty
                ? _newImages.map((x) => File(x.path)).toList()
                : null,
          ),
        );
  }

  // Warns user about unsaved changes before navigating back
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showAppDialog(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Leave without saving?',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Editing',
      isDestructive: true,
      icon: Icons.edit_off_outlined,
    );
    return result ?? false;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final totalImages = _existingImages.length + _newImages.length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final ok = await _onWillPop();
          if (ok && mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.deepSpace,
        extendBodyBehindAppBar: true,
        appBar: _buildGlassAppBar(isDark),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AdminCategoryBloc, AdminCategoryState>(
              listener: (context, state) {
                if (state is AdminCategoryLoaded) {
                  setState(() {
                    _categories = state.categories;
                    // Auto-select the product's current category on first load
                    if (_selectedCategory == null) {
                      try {
                        _selectedCategory = _categories.firstWhere(
                          (cat) => cat.id == widget.product.categoryId,
                        );
                      } catch (_) {
                        _selectedCategory = null;
                      }
                    } else {
                      // Clear selection if the category no longer exists in the list
                      if (!_categories
                          .any((c) => c.id == _selectedCategory!.id)) {
                        _selectedCategory = null;
                      }
                    }
                  });
                }
                if (state is AdminCategoryError) {
                  showAppSnackBar(context, state.message, isError: true);
                }
              },
            ),
            BlocListener<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminProductUpdated) {
                  setState(() => _isSubmitting = false);
                  showAppSnackBar(context, 'Product updated successfully!');
                  Navigator.pop(context, true);
                }
                if (state is AdminError) {
                  setState(() => _isSubmitting = false);
                  showAppSnackBar(context, state.message, isError: true);
                }
              },
            ),
          ],
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF0A0E1A),
                        Color(0xFF0D1F3C),
                        Color(0xFF0A0E1A),
                      ]
                    : [
                        Color.fromARGB(255, 236, 238, 244), // pure white
                        Color.fromARGB(255, 230, 233, 237), // soft bluish grey
                        Color.fromARGB(255, 231, 230, 239),
                      ],
              ),
            ),
            child: SlideTransition(
              position: _entrySlide,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 110, 16, 40),
                  children: [
                    // Images section
                    _buildSection(
                      isDark: isDark,
                      title: 'Product Images',
                      icon: Icons.photo_library_outlined,
                      trailingText: '$totalImages / 5',
                      child: _buildImagesSection(totalImages),
                    ),

                    const SizedBox(height: 16),

                    // Basic info section
                    _buildSection(
                      isDark: isDark,
                      title: 'Basic Info',
                      icon: Icons.info_outline_rounded,
                      child: _buildBasicInfo(),
                    ),

                    const SizedBox(height: 16),

                    // Variants section
                    _buildSection(
                      isDark: isDark,
                      title: 'Variants',
                      icon: Icons.tune_rounded,
                      child: _buildVariantsSection(isDark),
                    ),

                    const SizedBox(height: 28),

                    // Save button — disabled until there are changes
                    _buildSaveButton(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildGlassAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF0A0E1A),
                        Color(0xFF0D1F3C),
                        Color(0xFF0A0E1A),
                      ]
                    : [
                        Color.fromARGB(255, 255, 255, 255), // pure white
                        Color.fromARGB(255, 255, 255, 255), // soft bluish grey
                        Color.fromARGB(255, 255, 255, 255),
                      ],
              ),
              border: Border(
                bottom:
                    BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (_hasChanges) {
                          final ok = await _onWillPop();
                          if (ok && mounted) Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save shortcut in AppBar — only active when there are changes
                    AnimatedOpacity(
                      opacity: _hasChanges && !_isSubmitting ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: (_hasChanges && !_isSubmitting) ? _submit : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.neonCyan,
                                AppColors.neonPurple
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _hasChanges
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.neonCyan.withOpacity(0.35),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : [],
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.save_rounded,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section wrapper ──────────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
    String? trailingText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color(0xFF0A0E1A),
                      Color(0xFF0D1F3C),
                      Color(0xFF0A0E1A),
                    ]
                  : [
                      Color.fromARGB(255, 147, 181, 253), // pure white
                      Color.fromARGB(255, 121, 188, 255), // soft bluish grey
                      Color.fromARGB(255, 136, 123, 255),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header row with icon badge and optional trailing count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromARGB(255, 0, 255, 242),
                            ),
                          ),
                          child: Icon(icon,
                              color: Color.fromARGB(255, 0, 255, 242),
                              size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    if (trailingText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color.fromARGB(255, 0, 255, 242),
                          ),
                        ),
                        child: Text(
                          trailingText,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 255, 242),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.06), height: 1),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Images section ───────────────────────────────────────────────────────────

  Widget _buildImagesSection(int totalImages) {
    return Column(
      children: [
        if (_existingImages.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'CURRENT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _imageGrid(
            _existingImages.asMap().entries.map((entry) => _ImageTile(
                  key: ValueKey(entry.value),
                  isCover: entry.key == 0 && _newImages.isEmpty,
                  onRemove: () => _removeExistingImage(entry.value),
                  child: ProductImage(imageUrl: entry.value, fit: BoxFit.cover),
                )),
          ),
        ],
        if (_newImages.isNotEmpty) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _imageGrid(
            _newImages.asMap().entries.map((entry) => _ImageTile(
                  key: ValueKey(entry.value.path),
                  isCover: _existingImages.isEmpty && entry.key == 0,
                  onRemove: () => setState(() {
                    _newImages.removeAt(entry.key);
                    _hasChanges = true;
                  }),
                  child: Image.file(File(entry.value.path), fit: BoxFit.cover),
                )),
          ),
        ],
        // Empty state when no images are present
        if (totalImages == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Icon(Icons.image_outlined,
                        size: 36, color: Colors.white24),
                  ),
                  const SizedBox(height: 10),
                  const Text('No images added', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),

        const SizedBox(height: 14),

        // Gallery and Camera pick buttons
        Row(
          children: [
            Expanded(
              child: _GhostButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                disabled: totalImages >= 5,
                onTap: _pickFromGallery,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GhostButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                disabled: totalImages >= 5,
                onTap: _pickFromCamera,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imageGrid(Iterable<Widget> children) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children.toList(),
    );
  }

  // ─── Basic info section ───────────────────────────────────────────────────────

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _GlassInput(
          controller: _titleController,
          label: 'Product Title',
          icon: Icons.title_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title required' : null,
        ),
        const SizedBox(height: 14),
        _GlassInput(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description_outlined,
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Description required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _GlassInput(
                controller: _priceController,
                label: 'Price (₹)',
                icon: Icons.currency_rupee_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'Valid price required'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassInput(
                controller: _stockController,
                label: 'Stock',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Category dropdown with glass styling
        _GlassDropdown<Category>(
          value: _selectedCategory,
          hint: 'Select Category',
          icon: Icons.category_outlined,
          items: _categories
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (val) => setState(() {
            _selectedCategory = val;
            _hasChanges = true;
          }),
          validator: (val) => val == null ? 'Select a category' : null,
        ),
      ],
    );
  }

  // ─── Variants section ─────────────────────────────────────────────────────────

  Widget _buildVariantsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VariantGroup(
          label: 'Sizes',
          icon: Icons.straighten_rounded,
          items: _sizes,
          emptyHint: 'Default size will be used',
          onAdd: () => _showAddVariantSheet(
            isDark: isDark,
            label: 'Size',
            quickOptions: _quickSizes,
            current: _sizes,
            onAdd: (v) {
              if (!_sizes.contains(v)) {
                setState(() {
                  _sizes.add(v);
                  _hasChanges = true;
                });
              }
            },
          ),
          onDelete: (v) => setState(() {
            _sizes.remove(v);
            _hasChanges = true;
          }),
        ),
        const SizedBox(height: 20),
        _VariantGroup(
          label: 'Colors',
          icon: Icons.palette_outlined,
          items: _colors,
          emptyHint: 'Default color will be used',
          onAdd: () => _showAddVariantSheet(
            isDark: isDark,
            label: 'Color',
            quickOptions: _quickColors,
            current: _colors,
            onAdd: (v) {
              if (!_colors.contains(v)) {
                setState(() {
                  _colors.add(v);
                  _hasChanges = true;
                });
              }
            },
          ),
          onDelete: (v) => setState(() {
            _colors.remove(v);
            _hasChanges = true;
          }),
        ),
        // Shows a summary of how many variants will be created
        if (_sizes.isNotEmpty && _colors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: Color.fromARGB(255, 0, 255, 242)),
                const SizedBox(width: 8),
                Text(
                  '${_sizes.length * _colors.length} variant combinations will be saved',
                  style: const TextStyle(
                      fontSize: 12.5, color: Color.fromARGB(255, 0, 255, 242)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Save button ──────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    final active = _hasChanges && !_isSubmitting;
    return GestureDetector(
      onTap: active ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.neonCyan, AppColors.neonPurple],
          ),
          color: active ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.withOpacity(0.9),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasChanges ? Icons.save_rounded : Icons.save_rounded,
                      color: _hasChanges ? Colors.white : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasChanges ? 'Save Changes' : 'Save Changes',
                      style: TextStyle(
                        color: _hasChanges ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Image tile with remove button ───────────────────────────────────────────
// Displays a single product image in the grid with a cover badge and delete X.
class _ImageTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  final bool isCover;

  const _ImageTile({
    super.key,
    required this.child,
    required this.onRemove,
    this.isCover = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
        // Cover label shown on the first/primary image
        if (isCover)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.neonCyan, AppColors.neonPurple],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        // Red X button to remove the image
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glass text input ─────────────────────────────────────────────────────────
// Reusable glass-styled text field used throughout the product edit form.
class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _GlassInput({
    required this.controller,
    this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.autofocus = false,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autofocus: autofocus,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.09),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Glass dropdown ───────────────────────────────────────────────────────────
// Dropdown styled to match the dark glass aesthetic of the form.
class _GlassDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const _GlassDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      dropdownColor: const Color(0xFF1A2035),
      // iconEnabledColor: Colors.white38,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.09),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

// ─── Ghost outline button ─────────────────────────────────────────────────────
// Used for gallery/camera picker buttons — glass outline style.
class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(disabled ? 0.02 : 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 17,
                color: disabled
                    ? Colors.white24
                    : const Color.fromARGB(255, 255, 255, 255)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: disabled
                    ? Colors.white24
                    : const Color.fromARGB(255, 255, 255, 255),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Variant group ────────────────────────────────────────────────────────────
// Shows a list of size or color chips with an add button and delete on each chip.
class _VariantGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String emptyHint;
  final VoidCallback onAdd;
  final void Function(String) onDelete;

  const _VariantGroup({
    required this.label,
    required this.icon,
    required this.items,
    required this.emptyHint,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Color.fromARGB(255, 0, 255, 242),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 255, 242),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: Color.fromARGB(255, 0, 255, 242),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add $label',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 255, 242),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        items.isEmpty
            ? Text(emptyHint, style: const TextStyle(fontSize: 12.5))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 100, 55, 223)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(255, 21, 0, 248)
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => onDelete(e),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}
