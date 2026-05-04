// profile_screen.dart
import 'dart:ui';
import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:e_commerce_app/features/home/presentation/profile_edit_screen.dart';
import 'package:e_commerce_app/features/home/presentation/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../order/presentation/screens/order_history_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(isDark),
      appBar: _buildAppBar(context, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient(isDark),
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                final user = state.user;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    children: [
                      // Avatar with neon ring
                      _buildAvatar(user, isDark),
                      const SizedBox(height: 20),

                      // Name
                      Text(
                        user.name.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 13),
                      ),

                      const SizedBox(height: 36),

                      // Menu items
                      _MenuItem(
                        icon: Icons.edit_note_rounded,
                        title: 'Edit Profile',
                        isDark: isDark,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                          if (updated == true && context.mounted) {
                            context.read<AuthBloc>().add(AuthCheckRequested());
                          }
                        },
                      ),
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrderHistoryScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Shipping Address',
                        isDark: isDark,
                        onTap: () => showAppSnackBar(
                          context,
                          'Address management coming soon',
                          icon: Icons.lock_outline_rounded,
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen())),
                      ),

                      const SizedBox(height: 28),

                      // Logout button
                      _buildLogoutButton(context, isDark),
                    ],
                  ),
                );
              }
              return _buildGuestView(context, isDark);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY PROFILE',
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.glassFill(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.glassBorder(isDark)),
                        ),
                        child: Icon(Icons.settings_outlined,
                            color: AppColors.textPrimary(isDark), size: 18),
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

  Widget _buildAvatar(dynamic user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.neonCyan, AppColors.neonPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: AppColors.cardBg(isDark),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(52),
          child: user.avatar != null && user.avatar!.isNotEmpty
              ? AppImage(
                  imageUrl: user.avatar,
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover)
              : Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => showAppDialog(
        context,
        title: 'Logout',
        message: 'Are you sure you want to end your session?',
        confirmLabel: 'Logout',
        isDestructive: true,
        icon: Icons.power_settings_new_rounded,
        onConfirm: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.power_settings_new_rounded,
                  color: Colors.redAccent, size: 18),
              SizedBox(width: 10),
              Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 72, color: AppColors.textMuted(isDark)),
          const SizedBox(height: 20),
          Text(
            'AUTHENTICATION REQUIRED',
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonPurple]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Text(
                'LOGIN TO ACCESS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable menu row tile used in profile screen
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          // Light: white card with border; Dark: glass surface
          color: AppColors.glassFill(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder(isDark), width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.25)),
              ),
              child: Icon(icon, color: AppColors.neonCyan, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted(isDark), size: 20),
          ],
        ),
      ),
    );
  }
}
