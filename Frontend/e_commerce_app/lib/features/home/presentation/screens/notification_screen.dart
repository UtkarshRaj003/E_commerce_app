import 'dart:ui';

import 'package:e_commerce_app/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_event.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/widgets/common_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      // Dark space-like background with a mesh gradient
      backgroundColor: AppColors.deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A0E1A),
                      const Color(0xFF0D1F3C),
                      const Color(0xFF0A0E1A),
                    ]
                  : [
                      Color.fromARGB(255, 239, 240, 245),
                      Color.fromARGB(255, 238, 241, 244),
                      Color.fromARGB(255, 239, 238, 245),
                    ]),
        ),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            // Trigger data load if bloc hasn't fetched yet
            if (state is NotificationInitial) {
              context.read<NotificationBloc>().add(LoadNotifications());
              return const Center(child: LoadingWidget(message: 'Loading...'));
            }

            if (state is NotificationLoading) {
              return const Center(
                  child: LoadingWidget(message: 'Fetching notifications...'));
            }

            if (state is NotificationLoaded) {
              if (state.list.isEmpty) {
                return const EmptyWidget(
                  message: 'All caught up!\nNo new notifications.',
                  icon: Icons.notifications_off_outlined,
                );
              }

              return RefreshIndicator(
                color: AppColors.neonCyan,
                backgroundColor: const Color(0xFF0D1F3C),
                onRefresh: () async {
                  context.read<NotificationBloc>().add(LoadNotifications());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 110, 16, 24),
                  itemCount: state.list.length,
                  itemBuilder: (_, i) {
                    final n = state.list[i];
                    // Stagger each card's appearance using index-based delay
                    return _AnimatedNotificationCard(
                      index: i,
                      child: _NotificationCard(
                        title: n.title,
                        message: n.message,
                        isRead: n.isRead,
                        onTap: () {
                          context
                              .read<NotificationBloc>()
                              .add(MarkAsRead(n.id));
                        },
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              );
            }

            if (state is NotificationError) {
              return AppErrorWidget(
                message: 'Failed to load notifications',
                onRetry: () =>
                    context.read<NotificationBloc>().add(LoadNotifications()),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // Glass-style app bar that blurs the content behind it
  PreferredSizeWidget _buildGlassAppBar(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Pulse indicator for active/live status
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
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

// Wraps each notification card with a staggered slide-in animation.
// Delay is based on list index so cards appear one after another.
class _AnimatedNotificationCard extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedNotificationCard({required this.child, required this.index});

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
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
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Delay each card based on its position in the list for stagger effect
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
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

// Individual notification card with glass morphism styling.
// Unread notifications have a neon cyan left border and glow accent.
class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final bool isRead;
  final VoidCallback onTap;
  final bool isDark;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.isRead,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(isRead ? 0.05 : 0.1),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            Colors.grey.withOpacity(isRead ? 0.3 : 0.05),
                            Colors.grey.withOpacity(0.3),
                          ]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isRead
                      ? Colors.white.withOpacity(0.02)
                      : AppColors.neonCyan.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isRead
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.neonCyan.withOpacity(0.12),
                          blurRadius: 16,
                        ),
                      ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container — cyan for unread, grey for read
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.grey.withOpacity(0.3)
                          : AppColors.neonCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.withOpacity(0.4)
                            : AppColors.neonCyan.withOpacity(0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 18,
                      color: isRead ? Colors.grey[600] : AppColors.neonCyan,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isRead ? Colors.grey[600] : Colors.white,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unread dot indicator
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.7),
                            blurRadius: 8,
                          ),
                        ],
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
