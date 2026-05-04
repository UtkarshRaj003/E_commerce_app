// order_success_screen.dart
import 'dart:ui';
import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../common/models/order_model.dart';
import '../../../../core/utils/helpers.dart';
import '../../../home/presentation/screens/main_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _detailController;
  late Animation<double> _detailFade;
  late Animation<Offset> _detailSlide;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _detailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _detailFade =
        CurvedAnimation(parent: _detailController, curve: Curves.easeIn);
    _detailSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _detailController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showDetails = true);
        _detailController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Theme Management variables
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background colors based on theme
    final bgColor = isDark ? const Color(0xFF0A0E12) : const Color(0xFFF8F9FE);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white38 : Colors.black45;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Glow (Adapts to theme)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withOpacity(isDark ? 0.05 : 0.1),
              ),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Lottie.asset(
                    'assets/animations/success.json',
                    height: 200,
                    width: 200,
                    repeat: false,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      _lottieController.forward();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Order Placed! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your items will be with you soon',
                  style: TextStyle(color: secondaryTextColor, fontSize: 14),
                ),
                const SizedBox(height: 40),
                if (_showDetails)
                  Expanded(
                    child: FadeTransition(
                      opacity: _detailFade,
                      child: SlideTransition(
                        position: _detailSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildNeonOrderCard(widget.order, isDark,
                                  cardColor, textColor, secondaryTextColor),
                              const Spacer(),
                              _buildDoneButton(context),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonOrderCard(Order order, bool isDark, Color cardColor,
      Color textColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.neonCyan.withOpacity(isDark ? 0.15 : 0.3)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Order ID', '#${order.id.substring(0, 8).toUpperCase()}',
              textColor, secondaryColor),
          _neonDivider(isDark),
          _summaryRow('Amount', PriceFormatter.format(order.totalPrice),
              textColor, secondaryColor),
          _neonDivider(isDark),
          _summaryRow(
              'Payment', order.paymentMethod, textColor, secondaryColor),
          _neonDivider(isDark),
          _summaryRow(
              'Status', order.status.displayName, textColor, secondaryColor,
              isStatus: true),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label, String value, Color textColor, Color secondaryColor,
      {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: secondaryColor, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isStatus ? AppColors.neonCyan : textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _neonDivider(bool isDark) => Divider(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05),
      height: 1);

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: AppColors.neonCyan.withOpacity(0.4),
        ),
        child: const Text(
          'CONTINUE SHOPPING',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
