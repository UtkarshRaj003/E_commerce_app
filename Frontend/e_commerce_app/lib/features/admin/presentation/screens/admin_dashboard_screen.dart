import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_state.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_setting_screen.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Imports
import 'package:e_commerce_app/features/auth/presentation/screens/login_screen.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_product_screen.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_category_screen.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../bloc/admin_category_bloc.dart';
import '../bloc/admin_category_event.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    // Stats fetch karne ke liye
    context.read<AdminBloc>().add(AdminDashboardStatsRequested());
    // Users load karne ke liye (if stats doesn't include users)
    context.read<AdminBloc>().add(AdminUsersLoadRequested());
    // Categories fetch karne ke liye
    context.read<AdminCategoryBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Console Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.power_settings_new, color: Colors.redAccent),
              onPressed: () => _handleLogout(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, adminState) {
            return BlocBuilder<AdminCategoryBloc, AdminCategoryState>(
              builder: (context, catState) {
                if (adminState is AdminDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Extracting counts
                int productCount = 0;
                int orderCount = 0;
                int userCount = 0;
                int categoryCount = 0;

                if (adminState is AdminDashboardStats) {
                  productCount = adminState.totalProducts;
                  orderCount = adminState.totalOrders;
                  userCount = adminState.totalUsers;
                  categoryCount = adminState.totalCategories;
                }
                if (adminState is AdminUsersLoaded) {
                  userCount = adminState.users.length;
                }
                if (catState is AdminCategoryLoaded) {
                  categoryCount = catState.categories.length;
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
                              Color.fromARGB(255, 241, 242, 246),
                              Color.fromARGB(255, 242, 243, 247),
                              Color.fromARGB(255, 240, 241, 246),
                            ],
                    ),
                  ),
                  child: AnimationLimiter(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildHeaderSection(userCount),
                        const SizedBox(height: 25),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildStatCard(
                              context,
                              index: 0,
                              title: 'Products',
                              count: productCount.toString(),
                              icon: Icons.inventory_2_rounded,
                              color: Colors.blueAccent,
                              onTap: () =>
                                  _navigate(const AdminProductsScreen()),
                            ),
                            _buildStatCard(
                              context,
                              index: 1,
                              title: 'Orders',
                              count: orderCount.toString(),
                              icon: Icons.shopping_bag_rounded,
                              color: Colors.orangeAccent,
                              onTap: () => _navigate(const AdminOrdersScreen()),
                            ),
                            _buildStatCard(
                              context,
                              index: 2,
                              title: 'Categories',
                              count: categoryCount.toString(),
                              icon: Icons.category_rounded,
                              color: Colors.purpleAccent,
                              onTap: () =>
                                  _navigate(const AdminCategoryScreen()),
                            ),
                            _buildStatCard(
                              context,
                              index: 3,
                              title: 'Users',
                              count: userCount.toString(),
                              icon: Icons.people_alt_rounded,
                              color: const Color.fromARGB(255, 0, 255, 132),
                              onTap: () => _navigate(const AdminUserScreen()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _buildRecentActivitySection(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(int users) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 500),
      child: FadeInAnimation(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back, Admin!",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            const Text(
              "Operational Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required int index,
      required String title,
      required String count,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (event) => setState(() => isHovered = true),
      onExit: (event) => setState(() => isHovered = false),
      // cursor: SystemMouseCursors.click,
      child: AnimationConfiguration.staggeredGrid(
        position: index,
        duration: const Duration(milliseconds: 600),
        columnCount: 2,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? (isHovered
                          ? color.withOpacity(0.2)
                          : color.withOpacity(0.1))
                      : (isHovered
                          ? color.withOpacity(0.18)
                          : color.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? (isHovered
                            ? color.withOpacity(0.4)
                            : color.withOpacity(0.2))
                        : (isHovered
                            ? color.withOpacity(0.3)
                            : color.withOpacity(0.1)),
                    width: isHovered
                        ? 1.5
                        : 1.0, // Hover par border thodi thick hogi
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHovered
                          ? color.withOpacity(0.15)
                          : color.withOpacity(0.05),
                      blurRadius: isHovered ? 30 : 20,
                      offset:
                          isHovered ? const Offset(0, 15) : const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          count,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "System Healthy",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "All services are running smoothly.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _refreshData());
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit the admin panel?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AdminBloc>().add(AdminLogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
