// order_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../../common/models/order_model.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<OrderDetailBloc>()
        .add(OrderDetailLoadRequested(widget.orderId));
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
        child: BlocBuilder<OrderDetailBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const LoadingWidget(message: 'Loading order details...');
            }
            if (state is OrderError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<OrderDetailBloc>()
                    .add(OrderDetailLoadRequested(widget.orderId)),
              );
            }
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Animated status tracker at the top
                    _buildStatusTracker(order, isDark),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSection(
                            title: 'Items',
                            isDark: isDark,
                            child: _buildItemsList(order, isDark),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            title: 'Shipping Info',
                            isDark: isDark,
                            child: _buildShipping(order, isDark),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            title: 'Payment',
                            isDark: isDark,
                            child: _buildPayment(order, isDark),
                          ),
                          const SizedBox(height: 20),
                          _buildTotalCard(order, isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
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
                      'Order Details',
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

  // Status progress tracker — neon dots + connecting lines
  Widget _buildStatusTracker(Order order, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.glassFill(isDark),
        border: Border(
            bottom: BorderSide(color: AppColors.glassBorder(isDark), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StepDot(
              label: 'Placed',
              icon: Icons.receipt_long_rounded,
              step: OrderStatus.placed,
              current: order.status),
          _StepLine(step: OrderStatus.processing, current: order.status),
          _StepDot(
              label: 'Process',
              icon: Icons.settings_suggest_rounded,
              step: OrderStatus.processing,
              current: order.status),
          _StepLine(step: OrderStatus.shipped, current: order.status),
          _StepDot(
              label: 'Shipped',
              icon: Icons.local_shipping_rounded,
              step: OrderStatus.shipped,
              current: order.status),
          _StepLine(step: OrderStatus.delivered, current: order.status),
          _StepDot(
              label: 'Done',
              icon: Icons.verified_rounded,
              step: OrderStatus.delivered,
              current: order.status),
        ],
      ),
    );
  }

  // Glass section card wrapper with label
  Widget _buildSection(
      {required String title, required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
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
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildItemsList(Order order, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, __) =>
          Divider(color: AppColors.glassBorder(isDark), height: 20),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Row(
          children: [
            ProductImage(
              imageUrl: item.image,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${item.size} | ${item.color}',
                      style: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontSize: 12)),
                  Text('Qty: ${item.quantity}',
                      style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Text(PriceFormatter.format(item.totalPrice),
                style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }

  Widget _buildShipping(Order order, bool isDark) {
    final addr = order.shippingAddress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                color: AppColors.neonCyan, size: 16),
            const SizedBox(width: 8),
            Text(addr?.name ?? 'Customer',
                style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined,
                color: AppColors.textMuted(isDark), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${addr?.address}, ${addr?.city}, ${addr?.state} - ${addr?.pincode}',
                style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    height: 1.5,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayment(Order order, bool isDark) {
    return Column(
      children: [
        _InfoRow('Method', order.paymentMethod, isDark),
        _InfoRow('Status', order.isPaid ? 'Paid' : 'Pending', isDark,
            valueColor:
                order.isPaid ? Colors.greenAccent : Colors.orangeAccent),
        _InfoRow('Date', DateFormatter.formatDate(order.createdAt), isDark),
      ],
    );
  }

  Widget _buildTotalCard(Order order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withOpacity(isDark ? 0.15 : 0.1),
            AppColors.neonPurple.withOpacity(isDark ? 0.05 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.neonCyan.withOpacity(isDark ? 0.2 : 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Grand Total',
              style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          Text(PriceFormatter.format(order.totalPrice),
              style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, this.isDark, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary(isDark), fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// Animated status step dot
class _StepDot extends StatelessWidget {
  final String label;
  final IconData icon;
  final OrderStatus step;
  final OrderStatus current;

  const _StepDot(
      {required this.label,
      required this.icon,
      required this.step,
      required this.current});

  @override
  Widget build(BuildContext context) {
    final isDone = current.index >= step.index;
    final color = isDone ? AppColors.neonCyan : Colors.white24;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            boxShadow: isDone
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]
                : [],
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3)),
      ],
    );
  }
}

// Connecting line between status dots
class _StepLine extends StatelessWidget {
  final OrderStatus step;
  final OrderStatus current;

  const _StepLine({required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final isDone = current.index >= step.index;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDone
                ? [AppColors.neonCyan, AppColors.neonPurple]
                : [Colors.white12, Colors.white12],
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
