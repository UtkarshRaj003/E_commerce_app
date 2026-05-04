import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../order/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Single isDark check at the top — used throughout this build tree
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.scaffoldBg(isDark),
      appBar: _buildAppBar(isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient(isDark),
          ),
        ),
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartItemRemoved) {
              showAppSnackBar(context, 'Item removed from cart', isError: true);
            }
          },
          buildWhen: (prev, curr) =>
              curr is CartLoaded || curr is CartLoading || curr is CartError,
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                  child: LoadingWidget(message: 'Syncing cart...'));
            }
            if (state is CartError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<CartBloc>().add(CartLoadRequested()),
              );
            }
            if (state is CartLoaded) {
              if (state.cart.items.isEmpty) {
                return const EmptyWidget(
                  message: 'Your cart is empty',
                  icon: Icons.shopping_cart_outlined,
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.neonCyan,
                      backgroundColor: AppColors.cardBg(isDark),
                      onRefresh: () async =>
                          context.read<CartBloc>().add(CartLoadRequested()),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        itemCount: state.cart.items.length,
                        itemBuilder: (context, index) {
                          return _CartItem(
                            item: state.cart.items[index],
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ),
                  _SummaryBar(cart: state.cart, isDark: isDark),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // Glass app bar — dark is deep-space, light is frosted white
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.appBarFill(isDark),
              border: Border(
                bottom:
                    BorderSide(color: AppColors.appBarBorder(isDark), width: 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MY CART',
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
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
}

// Individual cart item card with glass styling
class _CartItem extends StatelessWidget {
  final dynamic item;
  final bool isDark;

  const _CartItem({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.glassFill(isDark),
        border: Border.all(color: AppColors.glassBorder(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image with subtle neon shadow
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ProductImage(
                    imageUrl: item.product.images.isNotEmpty
                        ? item.product.images.first
                        : '',
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${item.size}  •  ${item.color}',
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price in neon cyan — brand highlight
                      Text(
                        PriceFormatter.format(item.product.price),
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Delete button
                    GestureDetector(
                      onTap: () => context.read<CartBloc>().add(
                            CartRemoveItemRequested(
                              productId: item.product.id,
                              size: item.size,
                              color: item.color,
                            ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.red.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent, size: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quantity +/- controller
                    _QuantityRow(item: item, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Compact quantity +/- row
class _QuantityRow extends StatelessWidget {
  final dynamic item;
  final bool isDark;

  const _QuantityRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.07) : AppColors.lightCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder(isDark)),
      ),
      child: Row(
        children: [
          _btn(context, Icons.remove, () {
            if (item.quantity > 1) {
              context.read<CartBloc>().add(CartUpdateQuantityRequested(
                    productId: item.product.id,
                    size: item.size,
                    color: item.color,
                    quantity: item.quantity - 1,
                  ));
            }
          }, isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _btn(context, Icons.add, () {
            context.read<CartBloc>().add(CartUpdateQuantityRequested(
                  productId: item.product.id,
                  size: item.size,
                  color: item.color,
                  quantity: item.quantity + 1,
                ));
          }, isDark),
        ],
      ),
    );
  }

  Widget _btn(
      BuildContext context, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.textSecondary(isDark)),
      ),
    );
  }
}

// Bottom summary bar with total price and checkout button
class _SummaryBar extends StatelessWidget {
  final dynamic cart;
  final bool isDark;

  const _SummaryBar({required this.cart, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 100),
        decoration: BoxDecoration(
          // Light: frosted white card; Dark: charcoal panel
          color: isDark ? const Color(0xFF111827) : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.glassBorder(isDark), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                      color: AppColors.textSecondary(isDark), fontSize: 15),
                ),
                Text(
                  PriceFormatter.format(cart.totalPrice),
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Checkout button — neon gradient with glow
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonPurple],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
