// order_history_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../common/models/order_model.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../data/repositories/order_repository.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../bloc/order_detail_bloc.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadRequested());
  }

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
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const LoadingWidget(message: 'Fetching your orders...');
            }
            if (state is OrderError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<OrderBloc>().add(OrderLoadRequested()),
              );
            }
            if (state is OrderLoaded) {
              if (state.orders.isEmpty) {
                return const EmptyWidget(
                  message: 'No orders placed yet',
                  icon: Icons.shopping_bag_outlined,
                );
              }
              return RefreshIndicator(
                color: AppColors.neonCyan,
                backgroundColor: AppColors.cardBg(isDark),
                onRefresh: () async =>
                    context.read<OrderBloc>().add(OrderLoadRequested()),
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 450),
                        child: SlideAnimation(
                          verticalOffset: 40,
                          child: FadeInAnimation(
                            child: _OrderCard(order: order, isDark: isDark),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return const LoadingWidget();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.appBarFill(isDark),
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.appBarBorder(isDark), width: 1)),
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
                          color: AppColors.glassFill(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.glassBorder(isDark)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary(isDark), size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'My Orders',
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
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

// Individual order row card
class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isDark;

  const _OrderCard({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => OrderDetailBloc(ctx.read<OrderRepository>()),
            child: OrderDetailScreen(orderId: order.id),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glassFill(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder(isDark), width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Top row: order ID + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID',
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.glassBorder(isDark), height: 1),
            const SizedBox(height: 12),
            // Bottom row: date, items count, total
            Row(
              children: [
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  text: DateFormatter.formatDate(order.createdAt),
                  isDark: isDark,
                ),
                const Spacer(),
                _InfoTile(
                  icon: Icons.inventory_2_outlined,
                  text: '${order.itemCount} items',
                  isDark: isDark,
                ),
                const Spacer(),
                Text(
                  PriceFormatter.format(order.totalPrice),
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Payment status + navigate hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      order.isPaid
                          ? Icons.verified_rounded
                          : Icons.error_outline_rounded,
                      size: 13,
                      color: order.isPaid
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.isPaid ? 'PAID' : 'PENDING',
                      style: TextStyle(
                        color: order.isPaid
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'View Details →',
                  style: TextStyle(
                    color: AppColors.textMuted(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoTile(
      {required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted(isDark)),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                color: AppColors.textSecondary(isDark), fontSize: 12)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case OrderStatus.placed:
        color = Colors.blueAccent;
        break;
      case OrderStatus.processing:
        color = Colors.orangeAccent;
        break;
      case OrderStatus.shipped:
        color = Colors.purpleAccent;
        break;
      case OrderStatus.delivered:
        color = Colors.greenAccent;
        break;
      case OrderStatus.cancelled:
        color = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
