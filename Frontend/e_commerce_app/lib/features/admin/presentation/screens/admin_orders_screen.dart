import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../common/models/order_model.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String? updatingOrderId;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminOrdersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgDark =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color accentOrange = Colors.orangeAccent;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Order Management',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accentOrange),
            onPressed: () =>
                context.read<AdminBloc>().add(const AdminOrdersLoadRequested()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminOrderStatusUpdated) {
            setState(() => updatingOrderId = null);
            _showToast(context, 'Status Updated', Colors.green);
          }
          if (state is AdminError) {
            setState(() => updatingOrderId = null);
            _showToast(context, state.message, Colors.redAccent);
          }
        },
        builder: (context, state) {
          if (state is AdminOrdersLoading) {
            return Center(
                child: CircularProgressIndicator(color: accentOrange));
          }

          List<Order> orders = [];
          if (state is AdminOrdersLoaded) orders = state.orders;
          if (state is AdminOrderStatusUpdating) orders = state.orders;

          if (orders.isEmpty) {
            return const EmptyWidget(
              message: 'No active orders found',
              icon: Icons.auto_awesome_motion_rounded,
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _OrderCard(
                        order: order,
                        accentColor: accentOrange,
                        isUpdating: updatingOrderId == order.id,
                        onStatusChanged: (status) {
                          setState(() => updatingOrderId = order.id);
                          context.read<AdminBloc>().add(
                                AdminOrderStatusUpdateRequested(
                                    orderId: order.id, status: status),
                              );
                        },
                        cardColor: cardColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showToast(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Color cardColor;
  final Order order;
  final Color accentColor;
  final bool isUpdating;
  final Function(OrderStatus) onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.accentColor,
    required this.isUpdating,
    required this.onStatusChanged,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // TOP STRIP - ID & STATUS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.grey.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.numbers_rounded, color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '#${order.id.toUpperCase().substring(0, 8)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  _StatusBadge(
                    status: order.status,
                    isUpdating: isUpdating,
                    onChanged: onStatusChanged,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CUSTOMER INFO
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: accentColor.withOpacity(0.1),
                        child: Icon(Icons.person_outline_rounded,
                            color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.shippingAddress.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            Text(dateFormat.format(order.createdAt),
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(height: 1),
                  ),

                  // SHIPPING DETAIL
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${order.shippingAddress.address}, ${order.shippingAddress.city}',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // FOOTER: ITEMS & PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${order.itemCount} Items',
                            style: const TextStyle(fontSize: 12)),
                      ),
                      Row(
                        children: [
                          Text('Total: ',
                              style: TextStyle(color: Colors.grey[500])),
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isUpdating;
  final Function(OrderStatus) onChanged;

  const _StatusBadge(
      {required this.status,
      required this.isUpdating,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: isUpdating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : DropdownButtonHideUnderline(
              child: DropdownButton<OrderStatus>(
                value: status,
                dropdownColor: const Color(0xFF1E293B),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: _getStatusColor(status), size: 18),
                style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                items: OrderStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null && val != status) onChanged(val);
                },
              ),
            ),
    );
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return Colors.orangeAccent;
      case OrderStatus.processing:
        return Colors.blueAccent;
      case OrderStatus.shipped:
        return Colors.purpleAccent;
      case OrderStatus.delivered:
        return Colors.greenAccent;
      case OrderStatus.cancelled:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
