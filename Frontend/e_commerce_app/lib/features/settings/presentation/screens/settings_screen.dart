// settings_screen.dart — Futuristic glassmorphism settings UI
import 'dart:ui';

import 'package:e_commerce_app/features/home/presentation/profile_edit_screen.dart';
import 'package:e_commerce_app/features/home/presentation/screens/cart_screen.dart';
import 'package:e_commerce_app/features/home/presentation/screens/privacy_policy.dart';
import 'package:e_commerce_app/features/home/presentation/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import '../../../order/presentation/screens/order_history_screen.dart';
import '../../../../common/widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF0D1F3C), Color(0xFF0A0E1A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
          children: [
            // Account section
            _SectionHeader(label: 'Account', icon: Icons.person_rounded),
            const SizedBox(height: 10),
            _GlassSection(children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen())),
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                isDestructive: true,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Shopping section
            _SectionHeader(label: 'Shopping', icon: Icons.shopping_bag_rounded),
            const SizedBox(height: 10),
            _GlassSection(children: [
              _SettingsTile(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen())),
              ),
              _SettingsTile(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WishlistScreen())),
              ),
              _SettingsTile(
                icon: Icons.shopping_cart_outlined,
                label: 'Cart',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
            ]),

            const SizedBox(height: 24),

            // Appearance — dark mode toggle
            _SectionHeader(label: 'Appearance', icon: Icons.palette_rounded),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                  child: BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return SwitchListTile(
                        title: const Text('Dark Mode',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: Text(
                          state.isDarkMode ? 'Currently on' : 'Currently off',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.neonPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.dark_mode_outlined,
                              color: AppColors.neonPurple, size: 18),
                        ),
                        value: state.isDarkMode,
                        activeColor: const Color.fromARGB(255, 1, 113, 125),
                        onChanged: (_) =>
                            context.read<ThemeBloc>().add(ThemeToggled()),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Privacy & Legal
            _SectionHeader(
                label: 'Privacy & Legal', icon: Icons.security_rounded),
            const SizedBox(height: 10),
            _GlassSection(children: [
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen())),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TermsScreen())),
              ),
            ]),

            const SizedBox(height: 24),

            // App info section
            _SectionHeader(label: 'App', icon: Icons.info_rounded),
            const SizedBox(height: 10),
            _GlassSection(children: [
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                label: 'Clear Cache',
                onTap: () => showAppSnackBar(context, 'Cache Cleared',
                    icon: Icons.check_circle_outline_rounded),
              ),
              _SettingsTile(
                icon: Icons.tag_rounded,
                label: 'Version',
                trailing: const Text('1.0.0',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _glassAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1), width: 1)),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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

// Section header with an icon and label, used between grouped settings tiles
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 16),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// Glass container that groups related settings tiles with a separator
class _GlassSection extends StatelessWidget {
  final List<Widget> children;

  const _GlassSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            children: children
                .expand((child) => [
                      child,
                      if (child != children.last)
                        Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 1,
                            indent: 56),
                    ])
                .toList(),
          ),
        ),
      ),
    );
  }
}

// Individual row tile inside a settings glass section.
// Shows an icon container, label, optional custom trailing widget.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : AppColors.neonCyan;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
    );
  }
}
