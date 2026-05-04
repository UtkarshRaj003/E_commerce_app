import 'dart:ui';

import 'package:e_commerce_app/features/home/presentation/screens/notification_screen.dart';
import 'package:e_commerce_app/features/product/data/repositories/product_repository.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_event.dart';
import 'package:e_commerce_app/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:e_commerce_app/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:e_commerce_app/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/screens/product_detail_screen.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../../common/models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Triggers loading more products when user scrolls near the bottom (90%)
  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(ProductLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  // Fires a refresh with a selected category filter; null = show all
  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<ProductBloc>().add(
          ProductRefreshRequested(categoryId: categoryId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context, isDark),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Color(0xFF0A0E1A), Color(0xFF0D1F3C), Color(0xFF0A0E1A)]
                  : [
                      Color.fromARGB(255, 239, 240, 245),
                      Color.fromARGB(255, 238, 241, 244),
                      Color.fromARGB(255, 239, 238, 245),
                    ],
            ),
          ),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                    child: LoadingWidget(message: 'Loading products...'));
              }

              if (state is ProductError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context
                      .read<ProductBloc>()
                      .add(const ProductLoadRequested()),
                );
              }

              if (state is ProductLoaded) {
                return RefreshIndicator(
                  color: AppColors.neonCyan,
                  backgroundColor: const Color(0xFF0D1F3C),
                  onRefresh: () async {
                    context.read<ProductBloc>().add(
                          ProductRefreshRequested(
                              categoryId: _selectedCategoryId),
                        );
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Category filter chips row
                      SliverToBoxAdapter(
                        child: _buildCategories(state.categories),
                      ),

                      if (state.products.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyWidget(
                            message: 'No products found',
                            icon: Icons.inventory_2_outlined,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = state.products[index];
                                return _StaggeredProductCard(
                                  index: index,
                                  child:
                                      BlocBuilder<WishlistBloc, WishlistState>(
                                    builder: (context, wishlistState) {
                                      bool isInWishlist = false;
                                      if (wishlistState is WishlistLoaded) {
                                        isInWishlist = wishlistState
                                            .wishlist.items
                                            .any((item) =>
                                                item.id == product.id);
                                      }
                                      return ProductCard(
                                        isDark: isDark,
                                        title: product.title,
                                        images: product.images.isNotEmpty
                                            ? product.images
                                            : [],
                                        price: product.price,
                                        rating: product.rating,
                                        isInWishlist: isInWishlist,
                                        onAddToWishlist: () {
                                          context.read<WishlistBloc>().add(
                                                WishlistToggleRequested(
                                                    product.id),
                                              );
                                        },
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider(
                                                create: (context) =>
                                                    ProductDetailBloc(
                                                  context.read<
                                                      ProductRepository>(),
                                                )..add(ProductDetailLoadRequested(
                                                        product.id)),
                                                child: ProductDetailScreen(),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: state.products.length,
                            ),
                          ),
                        ),

                      // Pagination loading indicator shown at bottom of list
                      if (state is ProductLoaded && !state.hasReachedMax)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return const Center(child: LoadingWidget());
            },
          ),
        ),
      ),
    );
  }

  // Glass-style app bar with blur backdrop
  PreferredSizeWidget _buildGlassAppBar(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
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
                        Color(0xFF0A0E1A)
                      ]
                    : const [
                        Color.fromARGB(255, 241, 242, 246),
                        Color.fromARGB(255, 241, 244, 247),
                        Color.fromARGB(255, 242, 242, 247),
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
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // Logo mark and app name
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.neonPurple],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shopping_bag_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SHOP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    // Search icon button
                    _AppBarIconButton(
                      icon: Icons.search_rounded,
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: ProductSearchDelegate(
                            isDark: isDark,
                            onSearch: (query) {
                              context.read<ProductBloc>().add(
                                    ProductRefreshRequested(search: query),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _AppBarIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
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

  // Horizontal scrollable category filter row with glass chip styling
  Widget _buildCategories(List<Category> categories) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategoryId == null,
            onTap: () => _onCategorySelected(null),
          ),
          ...categories.map((category) => _CategoryChip(
                label: category.name,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => _onCategorySelected(
                    _selectedCategoryId == category.id ? null : category.id),
              )),
        ],
      ),
    );
  }
}

// Small glass icon button used in the app bar
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
        ),
      ),
    );
  }
}

// Glass-style filter chip for category selection
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.neonCyan, AppColors.neonPurple],
                )
              : const LinearGradient(
                  colors: [AppColors.neonCyan, AppColors.neonPurple],
                ),
          color: isSelected ? null : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.12),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// Wraps each product card with a staggered slide-up animation on first load
class _StaggeredProductCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredProductCard({required this.index, required this.child});

  @override
  State<_StaggeredProductCard> createState() => _StaggeredProductCardState();
}

class _StaggeredProductCardState extends State<_StaggeredProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Stagger delay capped at 6 items to avoid long waits for large lists
    final delay = (widget.index % 6) * 60;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}

// Search delegate with futuristic minimal styling
class ProductSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final bool isDark;

  ProductSearchDelegate({required this.onSearch, required this.isDark});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        color: isDark ? AppColors.deepSpace : Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white38),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear_rounded,
            color: isDark ? Colors.white54 : Colors.black54),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white54 : Colors.black54, size: 18),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSearch(query);
      close(context, query);
    });
    return Container(
      color: isDark ? AppColors.deepSpace : Colors.white,
      child: const Center(child: LoadingWidget()),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: isDark ? AppColors.deepSpace : Colors.white,
      child: Center(
        child: Text(
          'Search for products...',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      ),
    );
  }
}
