import 'dart:io';
import 'dart:ui';
import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_bloc.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_event.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Colors based on Dashboard Guidelines

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');

  List<Category> _categories = [];
  Category? _selectedCategory;
  final List<String> _sizes = [];
  final List<String> _colors = [];
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();

    context.read<AdminCategoryBloc>().add(FetchCategoriesEvent());
  }

  @override
  void dispose() {
    _entryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // --- Logic Functions ---

  void _showAdminSnack(String msg, Color cardColor, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.white : Colors.greenAccent),
            const SizedBox(width: 12),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black))),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source, Color cardColor) async {
    if (_images.length >= 5) {
      _showAdminSnack('Max 5 images allowed', cardColor, isError: true);
      return;
    }

    if (source == ImageSource.gallery) {
      final picked = await _picker.pickMultiImage(imageQuality: 70);
      if (picked.isNotEmpty) {
        setState(() => _images.addAll(picked.take(5 - _images.length)));
      }
    } else {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) setState(() => _images.add(picked));
    }
  }

  void _submitProduct(Color cardColor) {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _images.isEmpty) {
      if (_selectedCategory == null) {
        _showAdminSnack('Please select a category', cardColor, isError: true);
      } else if (_images.isEmpty) {
        _showAdminSnack('Add at least one image', cardColor, isError: true);
      }
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final variants = <Map<String, dynamic>>[];

    for (var s in (_sizes.isEmpty ? ['Default'] : _sizes)) {
      for (var c in (_colors.isEmpty ? ['Default'] : _colors)) {
        variants.add({'size': s, 'color': c, 'stock': stock});
      }
    }

    context.read<AdminBloc>().add(
          AdminProductCreateRequested(
            {
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim(),
              'price': price,
              'categoryId': _selectedCategory!.id,
              'variants': variants,
            },
            images: _images.map((x) => File(x.path)).toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color slateDark =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color accentColor = const Color.fromARGB(255, 63, 97, 248);
    return Scaffold(
      backgroundColor: slateDark,
      appBar: _buildGlassAppBar(isDark),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminProductCreated) {
            _showAdminSnack('Product Published!', cardColor);
            Navigator.pop(context);
          } else if (state is AdminError) {
            _showAdminSnack(state.message, cardColor, isError: true);
          }
        },
        child: BlocBuilder<AdminCategoryBloc, AdminCategoryState>(
          builder: (context, catState) {
            if (catState is AdminCategoryLoaded) {
              _categories = catState.categories;
            } else if (catState is AdminCategoryError) {
              return Center(
                child: Text(
                  catState.message,
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF0A0E1A),
                          Color(0xFF0D1F3C),
                          Color(0xFF0A0E1A),
                        ]
                      : const [
                          Color.fromARGB(255, 235, 236, 240),
                          Color.fromARGB(255, 232, 234, 239),
                          Color.fromARGB(255, 232, 233, 238),
                        ],
                ),
              ),
              child: SlideTransition(
                position: _entrySlide,
                child: Form(
                  key: _formKey,
                  child: AnimationLimiter(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 500),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildSectionHeader('Basic Information', accentColor,
                              Icons.info_outline_rounded),
                          _buildInfoCard(
                              cardColor, accentColor, slateDark, isDark),
                          const SizedBox(height: 25),
                          _buildSectionHeader('Variants & Inventory',
                              accentColor, Icons.layers_outlined),
                          _buildVariantCard(
                              accentColor, slateDark, cardColor, isDark),
                          const SizedBox(height: 25),
                          _buildSectionHeader('Product Media', accentColor,
                              Icons.image_outlined),
                          _buildImageCard(accentColor, cardColor, isDark),
                          const SizedBox(height: 40),
                          _buildSubmitButton(accentColor),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildGlassAppBar(bool isDark) {
    final theme = Theme.of(context);

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
                    ? const [
                        Color(0xFF0A0E1A),
                        Color(0xFF0D1F3C),
                        Color(0xFF0A0E1A),
                      ]
                    : const [
                        Color(0xFFFAFBFF),
                        Color(0xFFEFF4FF),
                        Color(0xFFFAFBFF),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // 🔙 BACK BUTTON
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // 🧾 TITLE
                    Expanded(
                      child: Text(
                        'Add Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 💾 SAVE BUTTON
                    GestureDetector(
                      onTap: () => _submitProduct(theme.colorScheme.primary),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.neonCyan, AppColors.neonPurple],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                        child: const Row(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Builders ---

  Widget _buildSectionHeader(String title, Color accentColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      Color cardColor, Color accentColor, Color slateDark, bool isDark) {
    return _buildContainer(
      isDark: isDark,
      child: Column(
        children: [
          _buildTextField(_titleController, 'Product Title', Icons.title,
              accentColor, slateDark,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _buildTextField(_descriptionController, 'Description',
              Icons.description, accentColor, slateDark,
              maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_priceController, 'Price (₹)',
                      Icons.currency_rupee, accentColor, slateDark,
                      isNumber: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(_stockController, 'Base Stock',
                      Icons.inventory_2, accentColor, slateDark,
                      isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Category>(
            dropdownColor: cardColor,
            value: _selectedCategory,
            decoration: _inputDecoration(
                'Category', Icons.category_outlined, accentColor),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(
      Color accentColor, Color slateDark, Color cardColor, bool isDark) {
    return _buildContainer(
      isDark: isDark,
      child: Column(
        children: [
          _buildVariantSection(
              'Available Sizes',
              _sizes,
              ['S', 'M', 'L', 'XL', 'XXL', '128GB', '256GB'],
              accentColor,
              cardColor,
              slateDark),
          const Divider(height: 32),
          _buildVariantSection(
              'Available Colors',
              _colors,
              ['Black', 'White', 'Red', 'Blue', 'Green', 'Gold'],
              accentColor,
              cardColor,
              slateDark),
        ],
      ),
    );
  }

  Widget _buildImageCard(Color accentColor, Color cardColor, bool isDark) {
    return _buildContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildImageAction(
                  Icons.photo_library_rounded,
                  'Gallery',
                  () => _pickImages(ImageSource.gallery, accentColor),
                  accentColor),
              const SizedBox(width: 12),
              _buildImageAction(
                  Icons.camera_alt_rounded,
                  'Camera',
                  () => _pickImages(ImageSource.camera, accentColor),
                  accentColor),
              const Spacer(),
              Text('${_images.length}/5',
                  style: TextStyle(
                      color: accentColor, fontWeight: FontWeight.bold)),
            ],
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_images[i].path),
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(i)),
                        child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 12)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color accentColor) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final isLoading = state is AdminProductCreating;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: isLoading ? null : () => _submitProduct(accentColor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              // Gradient style from GlassAppBar
              gradient: const LinearGradient(
                colors: [AppColors.neonCyan, AppColors.neonPurple],
              ),
              borderRadius:
                  BorderRadius.circular(16), // Thoda larger for main button
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonPurple.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'PUBLISH PRODUCT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // --- Reusable Small Widgets ---

  Widget _buildContainer({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, Color accentColor, Color slateDark,
      {int maxLines = 1,
      bool isNumber = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      decoration: _inputDecoration(label, icon, accentColor),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(
      String label, IconData icon, Color accentColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.grey[900], fontWeight: FontWeight.w600, fontSize: 14),
      prefixIcon: Icon(icon, color: accentColor, size: 20),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor.withOpacity(0.5))),
    );
  }

  Widget _buildVariantSection(
      String label,
      List<String> items,
      List<String> quickOptions,
      Color accentColor,
      Color cardColor,
      Color slateDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
            IconButton(
              onPressed: () => _showVariantPicker(label, items, quickOptions,
                  cardColor, accentColor, slateDark),
              icon: Icon(Icons.add_circle_outline_rounded, color: accentColor),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: items
              .map((item) => Chip(
                    backgroundColor: accentColor.withOpacity(0.1),
                    label: Text(item, style: const TextStyle(fontSize: 12)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: accentColor.withOpacity(0.2)),
                    onDeleted: () => setState(() => items.remove(item)),
                    deleteIconColor: Colors.redAccent,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildImageAction(
      IconData icon, String label, VoidCallback onTap, Color accentColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  void _showVariantPicker(String title, List<String> currentList,
      List<String> quick, Color cardColor, Color slateDark, Color accentColor) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add $title',
                style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: quick
                  .where((q) => !currentList.contains(q))
                  .map((q) => ActionChip(
                        backgroundColor: Color.fromARGB(255, 188, 242, 253),
                        label: Text(q,
                            style: TextStyle(
                                color: Color.fromARGB(255, 103, 159, 255))),
                        onPressed: () {
                          setState(() => currentList.add(q));
                          Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(),
              decoration:
                  _inputDecoration('Custom $title', Icons.edit, accentColor)
                      .copyWith(
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.check,
                                  color: Colors.greenAccent),
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  setState(() =>
                                      currentList.add(controller.text.trim()));
                                  Navigator.pop(ctx);
                                }
                              })),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
