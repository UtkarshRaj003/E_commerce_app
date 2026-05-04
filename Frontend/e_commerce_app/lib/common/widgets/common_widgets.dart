import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/utils/helpers.dart';

// Converts relative server image paths to full URLs.
// If path already starts with http, it's returned as-is (e.g. Google avatar URLs).
String getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith("http")) return path;
  return "https://e-commerce-app-t0my.onrender.com$path";
}

// Brand color palette — dark mode uses deep-space blacks,
// light mode uses premium cool-white/slate tones.
// Neon accent colors stay the same in both themes (brand identity).
class AppColors {
  // ── Neon accents (theme-agnostic) ──────────────────────────────────────────
  static const neonCyan = Color(0xFF00E5FF);
  static const neonPurple = Color(0xFF7C4DFF);
  static const neonGlow = Color(0xFF00E5FF);

  // ── Dark theme backgrounds ──────────────────────────────────────────────────
  static const deepSpace = Color(0xFF0A0E1A);
  static const glassSurface = Color(0x1AFFFFFF);
  static const glassEdge = Color(0x33FFFFFF);
  static const gradientStart = Color(0xFF0D1B2A);
  static const gradientMid = Color(0xFF1B2A4A);
  static const gradientEnd = Color(0xFF0A1628);

  // ── Light theme backgrounds (premium cool-white palette) ───────────────────
  static const lightBg = Color(0xFFF0F4FF); // scaffold background
  static const lightBgSecondary = Color(0xFFE8EDF8); // gradient mid-stop
  static const lightCard = Color(0xFFFFFFFF); // card surface
  static const lightCardAlt = Color(0xFFF5F7FF); // alternate card tint
  static const lightBorder = Color(0xFFDDE3F0); // subtle border line
  static const lightTextPrimary = Color(0xFF0D1B3E); // dark navy body text
  static const lightTextSecondary = Color(0xFF6B7A99); // muted label text

  // ── Theme-aware helpers ─────────────────────────────────────────────────────

  // Main scaffold/page background
  static Color scaffoldBg(bool isDark) => isDark ? deepSpace : lightBg;

  // Card / surface background
  static Color cardBg(bool isDark) =>
      isDark ? const Color(0xFF111827) : lightCard;

  // Translucent glass fill layer
  static Color glassFill(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.75);

  // Glass card border
  static Color glassBorder(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.1) : lightBorder;

  // Mesh background gradient colors
  static List<Color> bgGradient(bool isDark) => isDark
      ? [
          const Color(0xFF0A0E1A),
          const Color(0xFF0D1F3C),
          const Color(0xFF0A0E1A)
        ]
      : [lightBg, lightBgSecondary, lightBg];

  // Body text
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : lightTextPrimary;

  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white54 : lightTextSecondary;

  static Color textMuted(bool isDark) =>
      isDark ? Colors.white30 : const Color(0xFF9BA8BF);

  // AppBar/section border bottom line
  static Color appBarBorder(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.08) : lightBorder;

  // AppBar background fill (for glass blur container)
  static Color appBarFill(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.85);

  static LinearGradient get meshGradient => const LinearGradient(
        colors: [gradientStart, gradientMid, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

// Floating snackbar shown at the bottom of screen.
// Automatically dismisses after 1.2 seconds with a glass-style card design.
// Use this instead of default ScaffoldMessenger snackbar throughout the app.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _FloatingSnackBar(
      message: message,
      isError: isError,
      icon: icon,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1200), () {
    if (entry.mounted) entry.remove();
  });
}

// Internal widget that renders the floating snackbar with slide + fade animation.
class _FloatingSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _FloatingSnackBar({
    required this.message,
    required this.isError,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_FloatingSnackBar> createState() => _FloatingSnackBarState();
}

class _FloatingSnackBarState extends State<_FloatingSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? Colors.redAccent : AppColors.neonCyan;

    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      Colors.white.withOpacity(0.07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon ??
                            (widget.isError
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded),
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
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

// ─── Global Alert Dialog ──────────────────────────────────────────────────────
// Futuristic glass-style dialog used across the entire app for confirmations,
// warnings, and info prompts. Replaces all default AlertDialog usage.
//
// Usage:
//   showAppDialog(
//     context,
//     title: 'Delete?',
//     message: 'This cannot be undone.',
//     confirmLabel: 'Delete',
//     isDestructive: true,
//     onConfirm: () { ... },
//   );
Future<bool?> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  VoidCallback? onConfirm,
  IconData? icon,
}) {
  final confirmColor = isDestructive ? Colors.redAccent : AppColors.neonCyan;

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A2035),
                      const Color(0xFF0D1525),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: confirmColor.withOpacity(0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: confirmColor.withOpacity(0.12),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon badge at top
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: confirmColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: confirmColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: confirmColor.withOpacity(0.25),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Icon(
                            icon ??
                                (isDestructive
                                    ? Icons.delete_outline_rounded
                                    : Icons.help_outline_rounded),
                            color: confirmColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Dialog title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Description message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Action buttons row
                        Row(
                          children: [
                            // Cancel button — ghost style
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context, false),
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cancelLabel,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Confirm button — gradient with glow
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, true);
                                  onConfirm?.call();
                                },
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDestructive
                                          ? [
                                              Colors.redAccent,
                                              Colors.red.shade800,
                                            ]
                                          : [
                                              AppColors.neonCyan,
                                              AppColors.neonPurple,
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: confirmColor.withOpacity(0.4),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      confirmLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ─── Glass-effect container ────────────────────────────────────────────────────
// Glass-effect container used as a base for cards throughout the app.
// Applies backdrop blur + gradient border to give the frosted glass look.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.blurSigma = 12,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final glow = glowColor ?? AppColors.neonCyan;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: glow.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// General-purpose image widget supporting file, network, and empty states.
// Shows shimmer while loading and a person icon as placeholder for profiles.
class AppImage extends StatelessWidget {
  final String? imageUrl;
  final File? file;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    this.imageUrl,
    this.file,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    // Priority order: local File > Network URL > empty placeholder
    if (file != null) {
      image = Image.file(file!, width: width, height: height, fit: fit);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: getFullImageUrl(imageUrl!),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.white10,
          highlightColor: Colors.white24,
          child: Container(width: width, height: height, color: Colors.white10),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.white10,
          child: const Icon(Icons.image_not_supported, color: Colors.white38),
        ),
      );
    } else {
      image = Container(
        width: width,
        height: height,
        color: Colors.white10,
        child: const Icon(Icons.person, color: Colors.white38),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// Product-specific image widget with shimmer and error state.
// Used in product cards, cart items, wishlist, and order detail screens.
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: borderRadius,
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      );
    }

    Widget image = CachedNetworkImage(
      imageUrl: getFullImageUrl(imageUrl),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(width: width, height: height, color: Colors.white10),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.white10,
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// Product grid card with glassmorphism styling.
// Shows product image, title, price, rating, and wishlist toggle button.
class ProductCard extends StatelessWidget {
  final String title;
  final List<String> images;
  final double price;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToWishlist;
  final bool isInWishlist;
  final bool isDark; // 🔥 Added required boolean

  const ProductCard({
    super.key,
    required this.title,
    required this.images,
    required this.price,
    required this.isDark, // 🔥 Added to constructor
    this.rating = 0,
    this.onTap,
    this.onAddToCart,
    this.onAddToWishlist,
    this.isInWishlist = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = images.isNotEmpty ? images.first : '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              // 🔥 LOGIC: Dark theme colors vs Light theme colors
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.black.withOpacity(0.09),
                        Colors.white.withOpacity(0.03),
                      ]
                    : [
                        const Color(0xFFF0F2F8).withOpacity(0.8),
                        const Color(0xFFE6E9F0).withOpacity(0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image section
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child:
                            ProductImage(imageUrl: imageUrl, fit: BoxFit.cover),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Wishlist toggle button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onAddToWishlist,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isInWishlist
                                      ? Colors.red.withOpacity(0.3)
                                      : (isDark
                                          ? Colors.grey.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.05)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isInWishlist
                                        ? Colors.red.withOpacity(0.6)
                                        : (isDark
                                            ? Colors.grey.withOpacity(0.12)
                                            : Colors.black.withOpacity(0.1)),
                                  ),
                                  boxShadow: isInWishlist
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.4),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  isInWishlist
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isInWishlist
                                      ? Colors.red
                                      : (isDark
                                          ? Colors.white
                                          : Colors.black45),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product info section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            // 🔥 Title color logic
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PriceFormatter.format(price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors
                                .neonCyan, // Cyan dono par achha dikhta hai
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 11,
                                  // 🔥 Rating text color logic
                                  color:
                                      isDark ? Colors.white60 : Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Full-screen loading indicator with optional message.
// Uses shimmer-style pulsing container for futuristic feel.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing circular indicator inside a glass container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: AppColors.neonCyan.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neonCyan,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Error state widget shown when data fetch fails.
// Includes a retry button and neon-red error icon with glow.
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              _GlowButton(label: 'Retry', onTap: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty state widget shown when a list has no items.
// Shows a large icon and message, with optional action button.
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.4),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              _GlowButton(label: actionLabel!, onTap: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}

// Neon glow button used in error and empty state widgets.
// Has a subtle cyan glow shadow to match the futuristic theme.
class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.neonCyan, AppColors.neonPurple],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
