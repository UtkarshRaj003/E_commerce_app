// wishlist_screen.dart
import 'dart:ui';
import 'package:e_commerce_app/features/product/data/repositories/product_repository.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_event.dart';
import '../../../wishlist/presentation/bloc/wishlist_state.dart';
import '../../../product/presentation/screens/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistBloc>().add(WishlistLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        child: BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, state) {
            if (state is WishlistLoading) {
              return const Center(
                  child: LoadingWidget(message: 'Loading wishlist...'));
            }
            if (state is WishlistError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<WishlistBloc>().add(WishlistLoadRequested()),
              );
            }
            if (state is WishlistLoaded) {
              if (state.wishlist.items.isEmpty) {
                return const EmptyWidget(
                  message: 'Your wishlist is empty',
                  icon: Icons.favorite_outline,
                );
              }
              return RefreshIndicator(
                color: AppColors.neonCyan,
                backgroundColor: AppColors.cardBg(isDark),
                onRefresh: () async =>
                    context.read<WishlistBloc>().add(WishlistLoadRequested()),
                child: ListView.builder(
                  // padding: const EdgeInsets.symmetric(
                  //     horizontal: 20, vertical: 12),
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, MediaQuery.of(context).padding.bottom + 40),
                  itemCount: state.wishlist.items.length,
                  itemBuilder: (context, index) {
                    final product = state.wishlist.items[index];
                    return _WishlistItem(product: product, isDark: isDark);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

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
              child: Center(
                child: Text(
                  'FAVORITES',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistItem extends StatelessWidget {
  final dynamic product;
  final bool isDark;

  const _WishlistItem({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ProductDetailBloc(
              context.read<ProductRepository>(),
            )..add(ProductDetailLoadRequested(product.id)),
            child: const ProductDetailScreen(),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.glassFill(isDark),
          border: Border.all(color: AppColors.glassBorder(isDark), width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ProductImage(
                    imageUrl:
                        product.images.isNotEmpty ? product.images[0] : '',
                    width: 70,
                    height: 70,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Heart remove button
                  GestureDetector(
                    onTap: () {
                      context.read<WishlistBloc>().add(
                            WishlistRemoveItemRequested(product.id),
                          );
                      showAppSnackBar(
                        context,
                        'Removed from favorites',
                        isError: true,
                        icon: Icons.heart_broken,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.redAccent, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
