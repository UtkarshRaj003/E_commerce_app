import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../../../features/admin/presentation/bloc/admin_event.dart';
import 'edit_profile_screen.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../features/settings/presentation/bloc/theme_bloc.dart';
import '../../../../features/settings/presentation/bloc/theme_event.dart';
import '../../../../features/settings/presentation/bloc/theme_state.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color.fromARGB(255, 255, 255, 255),
        extendBodyBehindAppBar: true,
        appBar: _buildGlassAppBar(context),
        body: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              // 🔥 Background fix (dark vs light)
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
                          Color.fromARGB(255, 228, 232, 255), // pure white
                          Color.fromARGB(
                              255, 174, 213, 252), // soft bluish grey
                          Color.fromARGB(255, 183, 175, 255),
                        ],
                ),
              ),

              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  final isDark = themeState.isDarkMode;

                  return AnimationLimiter(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 450),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 40.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildAdminHeroCard(context),

                          const SizedBox(height: 28),

                          _SectionLabel(label: 'ACCOUNT MANAGEMENT'),
                          const SizedBox(height: 12),

                          _GlassSettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Admin name, phone & office address',
                            accentColor: theme.colorScheme.primary, // 🔥 fix
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminEditProfileScreen(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          _SectionLabel(label: 'APPEARANCE & UI'),
                          const SizedBox(height: 12),

                          _GlassToggleTile(
                            icon: isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: isDark
                                ? 'System is in dark mode'
                                : 'System is in light mode',
                            value: isDark,
                            accentColor: theme.colorScheme.secondary, // 🔥 fix
                            onChanged: (_) =>
                                context.read<ThemeBloc>().add(ThemeToggled()),
                          ),

                          const SizedBox(height: 24),

                          _SectionLabel(label: 'SYSTEM ACTIONS'),
                          const SizedBox(height: 12),

                          _GlassSettingsTile(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            subtitle: 'Exit admin secure session',
                            accentColor:
                                Colors.red, // 🔥 keep destructive clear
                            isDestructive: true,
                            onTap: () => _handleLogout(context),
                          ),

                          const SizedBox(height: 40),

                          // 🔥 Footer text fix
                          Center(
                            child: Text(
                              'v2.4.0 (Stable)',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.8),
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ));
  }

  // Glass-blur AppBar with ADMIN CONSOLE title and neon pulse dot
  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                        Color(0xFF0A0E1A)
                      ]
                    : const [
                        Color.fromARGB(255, 228, 232, 255),
                        Color.fromARGB(255, 174, 213, 252),
                        Color.fromARGB(255, 183, 175, 255),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. BACK BUTTON (Exactly at Start)
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                    // 2. CENTERED TEXT WITH DOTS
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // LEFT DOT
                            _buildGlowingDot(theme.colorScheme.primary, isDark),

                            const SizedBox(width: 12),

                            Text(
                              'ADMIN CONSOLE',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    15, // Slightly reduced to fit small screens
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // RIGHT DOT
                            _buildGlowingDot(
                              isDark
                                  ? AppColors.neonPurple
                                  : theme.colorScheme.secondary,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. DUMMY SPACER (To keep title perfectly centered)
                    const SizedBox(
                        width: 40), // Same width as back button container
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Helper widget for clean code
  Widget _buildGlowingDot(Color color, bool isDark) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  // Admin identity card shown at the top of the settings list
  Widget _buildAdminHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: isDark ? 14 : 6, sigmaY: isDark ? 14 : 6),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            // 🔥 Gradient fix
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.neonPurple.withOpacity(0.18),
                      AppColors.neonCyan.withOpacity(0.06),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.neonPurple.withOpacity(0.18),
                      AppColors.neonCyan.withOpacity(0.06),
                    ],
                  ),

            borderRadius: BorderRadius.circular(24),

            // 🔥 Border fix
            border: Border.all(
              color: isDark
                  ? AppColors.neonPurple.withOpacity(0.3)
                  : AppColors.neonPurple.withOpacity(0.3),
              width: 1,
            ),

            // 🔥 Shadow fix
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: AppColors.neonPurple.withOpacity(0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.neonPurple.withOpacity(0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // ICON BOX
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [AppColors.neonPurple, AppColors.neonCyan],
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.neonPurple,
                            AppColors.neonCyan,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.neonPurple.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.7),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.7),
                                      blurRadius: 6,
                                    ),
                                  ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secure session active',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                            fontSize: 12.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // VERSION BADGE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  'v2.4.0',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logout uses the global showAppDialog for consistent styling across the app
  void _handleLogout(BuildContext context) {
    showAppDialog(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to end your secure admin session?',
      confirmLabel: 'LOGOUT',
      cancelLabel: 'CANCEL',
      isDestructive: true,
      icon: Icons.logout_rounded,
      onConfirm: () {
        context.read<AdminBloc>().add(AdminLogoutRequested());
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
// Small all-caps label shown above each settings group.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.neonCyan, AppColors.neonPurple],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 17, 193, 212),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass settings tile ──────────────────────────────────────────────────────
// Standard tappable row card used for navigation actions like Edit Profile.
// Destructive tiles (logout) get a red glow accent.
class _GlassSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _GlassSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDestructive
                    ? [
                        Colors.redAccent.withOpacity(0.08),
                        Colors.redAccent.withOpacity(0.12),
                      ]
                    : [
                        Colors.blue.withOpacity(0.09),
                        Colors.blue.withOpacity(0.15),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDestructive
                    ? Colors.redAccent.withOpacity(0.3)
                    : Colors.lightBlueAccent.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: isDestructive
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.06),
                        blurRadius: 16,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Icon badge with matching accent color background
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDestructive
                              ? Colors.redAccent
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive
                      ? Colors.redAccent.withOpacity(0.5)
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass toggle tile ────────────────────────────────────────────────────────
// Settings tile with an inline Switch for boolean preferences like Dark Mode.
// Switch thumb color matches the neon accent for consistency.
class _GlassToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accentColor;
  final void Function(bool) onChanged;

  const _GlassToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: value
                  ? [
                      Colors.grey.withOpacity(0.08),
                      Colors.grey.withOpacity(0.12),
                    ]
                  : [
                      Colors.blueGrey.withOpacity(0.1),
                      Colors.blueGrey.withOpacity(0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value
                  ? Colors.blueGrey.withOpacity(0.3)
                  : Colors.blueGrey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon badge that glows when switch is on
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(value ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withOpacity(value ? 0.4 : 0.15),
                  ),
                  boxShadow: value
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 14,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: value ? accentColor : accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom neon-styled switch
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: accentColor,
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
