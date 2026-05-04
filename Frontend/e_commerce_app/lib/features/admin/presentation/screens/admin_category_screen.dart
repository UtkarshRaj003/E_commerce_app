import 'dart:io';
import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_bloc.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_event.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Added for consistency
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // UI Constants based on Dashboard
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    context.read<AdminCategoryBloc>().add(FetchCategoriesEvent());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
      body: BlocConsumer<AdminCategoryBloc, AdminCategoryState>(
        listener: (context, state) {
          if (state is AdminCategorySuccess) {
            _showCustomSnackBar(context, state.message, isError: false);
          } else if (state is AdminCategoryError) {
            _showCustomSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is AdminCategoryLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          if (state is AdminCategoryLoaded) {
            if (state.categories.isEmpty) {
              return _buildEmptyState(context);
            }

            return AnimationLimiter(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildCategoryCard(
                            context, category, cardColor, isDark),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purpleAccent,
        onPressed: () => _showAddCategoryDialog(context),
        label: const Text('New Category',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildCategoryCard(
      BuildContext context, Category category, Color cardColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.purpleAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: category.image != null && category.image!.isNotEmpty
                ? AppImage(
                    imageUrl: category.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover)
                : Center(
                    child: Text(
                      category.name.isNotEmpty
                          ? category.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent),
                    ),
                  ),
          ),
        ),
        title: Text(
          category.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Created: ${category.createdAt != null ? DateFormat('dd MMM yyyy').format(category.createdAt!) : "N/A"}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(Icons.edit_rounded, Colors.blueAccent,
                () => _showAddCategoryDialog(context, category: category)),
            const SizedBox(width: 8),
            _buildActionButton(Icons.delete_outline_rounded, Colors.redAccent,
                () => _confirmDelete(context, category.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // --- Dialogs & Feedback ---

  void _showCustomSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.white : Colors.greenAccent),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message,
                    style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.white))),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Category?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This action will remove the category permanently.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.read<AdminCategoryBloc>().add(DeleteCategoryEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Edit/Add Dialog simplified with Dashboard styling
  void _showAddCategoryDialog(BuildContext context, {Category? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    File? selectedImage;
    final categoryBloc = context.read<AdminCategoryBloc>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(category == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setDialogState(() => selectedImage = File(pickedFile.path));
                  }
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(selectedImage!, fit: BoxFit.cover))
                      : (category?.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AppImage(
                                  imageUrl: category!.image!,
                                  fit: BoxFit.cover))
                          : const Icon(Icons.add_a_photo_rounded,
                              color: Colors.purpleAccent, size: 32)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Category Name',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  if (category == null) {
                    categoryBloc.add(CreateCategoryEvent(
                        name: name, imageFile: selectedImage));
                  } else {
                    categoryBloc.add(UpdateCategoryEvent(
                        id: category.id, name: name, imageFile: selectedImage));
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(category == null ? 'Create' : 'Save Changes',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No categories found',
              style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}
