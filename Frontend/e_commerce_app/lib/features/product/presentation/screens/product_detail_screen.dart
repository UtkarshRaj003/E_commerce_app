import 'dart:ui';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_event.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_state.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../common/widgets/common_widgets.dart';
// Blocs and Events remain same...

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 🔥 FIX 1: Dynamic Background Color
      backgroundColor: isDark ? AppColors.deepSpace : const Color(0xFFF8F9FE),
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) return const LoadingWidget();
          if (state is ProductDetailError)
            return AppErrorWidget(message: state.message);

          if (state is ProductDetailLoaded) {
            final product = state.product;
            return Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildGlassAppBar(product, isDark), // Pass isDark if needed
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndPrice(
                                product, isDark), // Fix colors inside
                            const SizedBox(height: 24),
                            _buildVariantSection(
                                "Select Size",
                                product.variants
                                    .map((v) => v.size)
                                    .toSet()
                                    .toList(),
                                true,
                                isDark), // isDark already added by us
                            const SizedBox(height: 16),
                            _buildVariantSection(
                                "Select Color",
                                product.variants
                                    .map((v) => v.color)
                                    .toSet()
                                    .toList(),
                                false,
                                isDark),
                            const SizedBox(height: 24),
                            _buildDescription(
                                product, isDark), // Fix colors inside

                            // 🔥 FIX 2: Bottom space adjusted for Safe Area
                            SizedBox(
                                height: MediaQuery.of(context).padding.bottom +
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 🔥 FIX 3: Bottom Action with SafeArea
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlocConsumer<CartBloc, CartState>(
                    listener: (context, cartState) {
                      if (cartState is CartItemAdded) {
                        showAppSnackBar(
                          context,
                          "Product added to cart successfully!",
                          isError: false,
                          icon: Icons.shopping_cart_checkout_rounded,
                        );
                      }
                    },
                    builder: (context, cartState) {
                      // Wrap with SafeArea to avoid system bar overlap
                      return SafeArea(
                        top: false,
                        child: _buildBottomAction(product, isDark),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildGlassAppBar(product, bool isDark) {
    return SliverAppBar(
      expandedHeight: 400,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: product.images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (context, i) =>
                  ProductImage(imageUrl: product.images[i]),
            ),
            // Bottom Gradient Overlay for readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.deepSpace],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndPrice(product, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            // 🔥 Fix: Dynamic Title Color
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              PriceFormatter.format(product.price),
              style: const TextStyle(
                fontSize: 24,
                color:
                    AppColors.neonCyan, // Cyan dono themes par accha dikhta hai
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildQuantityController(isDark), // 🔥 Added isDark
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityController(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        // 🔥 Fix: Adaptive background & border
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null),
            icon: Icon(Icons.remove,
                color: isDark ? Colors.white70 : Colors.black54),
          ),
          Text(
            '$_quantity',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: Icon(Icons.add,
                color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection(
      String title, List<String> options, bool isSize, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            // LIGHT: Black54 | DARK: White70
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: options.map((opt) {
            bool isSelected =
                isSize ? _selectedSize == opt : _selectedColor == opt;

            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (val) => setState(
                  () => isSize ? _selectedSize = opt : _selectedColor = opt),

              // Selected Color: Neon Purple logic
              selectedColor:
                  AppColors.neonPurple.withOpacity(isDark ? 0.3 : 0.2),

              // Background: Subtle Dark vs Subtle Light
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),

              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.neonPurple
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),

              // Material 3 chips mein border ke liye 'side' property:
              side: BorderSide(
                color: isSelected
                    ? AppColors.neonPurple
                    : (isDark ? Colors.white12 : Colors.black12),
                width: 1,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              // Extra Cleanup: Chip ke default effects hatane ke liye (optional)
              showCheckmark: false, // Checkmark hata diya cleaner look ke liye
              pressElevation: 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription(product, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            // 🔥 Fix: Dynamic heading color
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(
            // 🔥 Fix: Dynamic body color
            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(product, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // 🔥 Fix: Glass effect for both themes
            color: isDark
                ? AppColors.deepSpace.withOpacity(0.8)
                : Colors.white.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                  color:
                      isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _handleAddToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.black, // Text color on button
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'ADD TO CART',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(product) {
    if (_selectedSize == null || _selectedColor == null) {
      showAppSnackBar(
        context,
        "Please select size and color!",
        isError: true, // Red accent trigger
      );
      return;
    }
    context.read<CartBloc>().add(CartAddItemRequested(
          productId: product.id,
          size: _selectedSize!,
          color: _selectedColor!,
          quantity: _quantity,
        ));
  }
}
