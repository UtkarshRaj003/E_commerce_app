import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts([String? query]) {
    context.read<AdminBloc>().add(
          AdminProductsLoadRequested(
            search: (query == null || query.isEmpty) ? null : query,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgDark =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color accentOrange = Colors.blueAccent;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Inventory',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accentOrange),
            onPressed: () => _loadProducts(_searchController.text),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentOrange,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          _loadProducts(_searchController.text);
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Product',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminProductDeleted ||
              state is AdminProductCreated ||
              state is AdminProductUpdated) {
            _showSnackBar(context, 'Inventory Updated Successfully',
                Colors.green, cardColor);
            _loadProducts(_searchController.text);
          }
          if (state is AdminError) {
            _showSnackBar(context, state.message, Colors.redAccent, cardColor);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchBar(cardColor, accentOrange),
              Expanded(
                child: _buildStateContent(state, cardColor, accentOrange),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(Color cardColor, Color accentOrange) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _loadProducts,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            // --- FIX STARTS HERE ---
            filled: true,
            fillColor: Colors.transparent,
            hoverColor: Colors.transparent, // Prevents highlight on web/desktop
            // -----------------------
            hintText: 'Search stock...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search_rounded, color: accentOrange),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon:
                        const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      _loadProducts('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(
      AdminState state, Color cardColor, Color accentOrange) {
    if (state is AdminProductsLoading) {
      return Center(child: CircularProgressIndicator(color: accentOrange));
    }

    if (state is AdminError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => _loadProducts(_searchController.text),
      );
    }

    if (state is AdminProductsLoaded) {
      if (state.products.isEmpty) {
        return const EmptyWidget(
          message: 'No products found',
          icon: Icons.inventory_2_outlined,
        );
      }

      return RefreshIndicator(
        color: accentOrange,
        onRefresh: () async => _loadProducts(_searchController.text),
        child: AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final p = state.products[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _ProductListItem(
                      product: p,
                      accentColor: accentOrange,
                      cardColor: cardColor,
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: p)),
                        );
                        _loadProducts(_searchController.text);
                      },
                      onDelete: () =>
                          _confirmDelete(context, p.id, p.title, cardColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showSnackBar(
      BuildContext context, String msg, Color color, Color cardColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String productId, String name, Color cardColor) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Product?',
            ),
        content: Text(
            'Are you sure you want to delete "$name"? This action cannot be undone.',
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Keep', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dContext);
              context
                  .read<AdminBloc>()
                  .add(AdminProductDeleteRequested(productId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final dynamic product; // Replace with your Product model
  final Color accentColor;
  final Color cardColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListItem({
    required this.product,
    required this.accentColor,
    required this.cardColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 0.1,
            offset: const Offset(0, 4),
            spreadRadius: 0.1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ProductImage(
              imageUrl: product.images.isNotEmpty ? product.images.first : '',
              width: 60,
              height: 60,
            ),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '₹${product.price.toStringAsFixed(2)}',
            style: TextStyle(
                color: accentColor, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
                icon: Icons.edit_note_rounded,
                color: Colors.blueAccent,
                onTap: onEdit),
            const SizedBox(width: 8),
            _ActionButton(
                icon: Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
