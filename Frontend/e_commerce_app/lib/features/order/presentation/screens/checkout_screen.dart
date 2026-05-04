// checkout_screen.dart — theme-aware
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../common/models/cart_model.dart';
import '../../../../common/models/user_model.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/bloc/order_event.dart';
import '../../../order/presentation/bloc/order_state.dart';
import '../../../order/presentation/screens/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  late Razorpay _razorpay;
  String? backendOrderId;

  Address? _savedAddress;
  bool _addressLoading = true;
  bool _isEditingAddress = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.name;
      _phoneController.text = state.user.phone ?? '';
      _emailController.text = state.user.email;
    }
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddress());
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    try {
      final repo = context.read<UserRepository>();
      final user = await repo.getProfile();
      final authState = context.read<AuthBloc>().state;
      setState(() {
        if (authState is AuthAuthenticated) {
          _nameController.text = authState.user.name;
          _phoneController.text = authState.user.phone ?? '';
          _emailController.text = authState.user.email;
        }
        if (user.addresses.isNotEmpty) {
          final addr = user.addresses.first;
          _savedAddress = addr;
          _addressController.text = addr.addressLine;
          _cityController.text = addr.city;
          _stateController.text = addr.state;
          _pincodeController.text = addr.pincode;
        }
        _addressLoading = false;
      });
    } catch (_) {
      setState(() => _addressLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      final items = cartState.cart.items
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
                'price': item.product.price,
                'variant': {'size': item.size, 'color': item.color}
              })
          .toList();
      context.read<OrderBloc>().add(PlaceOrderRequested(
            items: items,
            totalAmount: cartState.cart.totalPrice,
            paymentMethod: 'Razorpay',
            razorpayOrderId: backendOrderId,
            shippingAddress: _shippingMap(),
          ));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showAppSnackBar(context, 'Payment failed: ${response.message}',
        isError: true);
  }

  Map<String, String> _shippingMap() => {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
      };

  void _placeOrder(Cart cart) {
    final items = cart.items
        .map((item) => {
              'productId': item.productId,
              'quantity': item.quantity,
              'price': item.product.price,
              'variant': {'size': item.size, 'color': item.color}
            })
        .toList();
    context.read<OrderBloc>().add(PlaceOrderRequested(
          items: items,
          totalAmount: cart.totalPrice,
          paymentMethod: 'COD',
          shippingAddress: _shippingMap(),
        ));
  }

  void _processCheckout() {
    if (!_formKey.currentState!.validate()) return;
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;
    final cart = cartState.cart;

    if (_paymentMethod == 'Razorpay') {
      if (cart.totalPrice > 500000) {
        showAppSnackBar(context, 'Use COD for large orders', isError: true);
        return;
      }
      final items = cart.items
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
                'price': item.product.price,
                'variant': {'size': item.size, 'color': item.color}
              })
          .toList();
      context.read<OrderBloc>().add(PaymentCreateRequested(
            amount: cart.totalPrice,
            items: items,
            shippingAddress: _shippingMap(),
          ));
    } else {
      _placeOrder(cart);
    }
  }

  void _openRazorpay(Map<String, dynamic> data) {
    try {
      _razorpay.open({
        'key': 'rzp_test_SezmzZsCWF5EVZ',
        'amount': data['amount'],
        'order_id': data['razorpayOrderId'],
        'currency': 'INR',
        'name': _nameController.text,
        'description': 'Order Payment',
        'prefill': {
          'contact': _phoneController.text,
          'email': _emailController.text,
        },
        'theme': {'color': '#00E5FF'},
      });
    } catch (e) {
      debugPrint('RAZORPAY ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          context.read<CartBloc>().add(CartClearRequested());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => OrderSuccessScreen(order: state.order)));
        }
        if (state is PaymentOrderCreated) {
          backendOrderId = state.paymentData['orderId'];
          _openRazorpay(state.paymentData);
        }
        if (state is OrderError) {
          showAppSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
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
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoaded) {
                return const Center(child: LoadingWidget());
              }
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _SectionLabel(
                              icon: Icons.location_on_outlined,
                              title: 'SHIPPING DETAILS',
                              isDark: isDark),
                          const SizedBox(height: 10),
                          _buildAddressCard(isDark),
                          const SizedBox(height: 22),
                          _SectionLabel(
                              icon: Icons.payments_outlined,
                              title: 'PAYMENT METHOD',
                              isDark: isDark),
                          const SizedBox(height: 10),
                          _PaymentOption(
                            value: 'COD',
                            title: 'Cash on Delivery',
                            icon: Icons.money_rounded,
                            selected: _paymentMethod == 'COD',
                            isDark: isDark,
                            onTap: () => setState(() => _paymentMethod = 'COD'),
                          ),
                          const SizedBox(height: 10),
                          _PaymentOption(
                            value: 'Razorpay',
                            title: 'Online Payment',
                            icon: Icons.account_balance_wallet_outlined,
                            selected: _paymentMethod == 'Razorpay',
                            isDark: isDark,
                            onTap: () =>
                                setState(() => _paymentMethod = 'Razorpay'),
                          ),
                          const SizedBox(height: 22),
                          _SectionLabel(
                              icon: Icons.shopping_cart_outlined,
                              title: 'ORDER SUMMARY',
                              isDark: isDark),
                          const SizedBox(height: 10),
                          _buildSummary(cartState.cart, isDark),
                        ],
                      ),
                    ),
                    _buildBottomBar(cartState.cart, isDark),
                  ],
                ),
              );
            },
          ),
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
                    Text('CHECKOUT',
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(bool isDark) {
    if (_addressLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Saved address display mode
    if (_savedAddress != null && !_isEditingAddress) {
      return _GlassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_nameController.text,
                    style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                GestureDetector(
                  onTap: () => setState(() => _isEditingAddress = true),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded,
                          color: AppColors.neonCyan, size: 16),
                      const SizedBox(width: 4),
                      const Text('Change',
                          style: TextStyle(
                              color: AppColors.neonCyan, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_phoneController.text}  •  ${_emailController.text}',
              style: TextStyle(
                  color: AppColors.textSecondary(isDark), fontSize: 12),
            ),
            Divider(color: AppColors.glassBorder(isDark), height: 20),
            Text(
              '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}',
              style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  height: 1.5,
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Edit/input mode
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          _CheckoutField(_nameController, 'Name', isDark),
          _CheckoutField(_phoneController, 'Phone', isDark,
              type: TextInputType.phone),
          _CheckoutField(_emailController, 'Email', isDark,
              type: TextInputType.emailAddress),
          _CheckoutField(_addressController, 'Address Line', isDark),
          Row(
            children: [
              Expanded(child: _CheckoutField(_cityController, 'City', isDark)),
              const SizedBox(width: 10),
              Expanded(
                  child: _CheckoutField(_pincodeController, 'Pincode', isDark,
                      type: TextInputType.number)),
            ],
          ),
          if (_savedAddress != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isEditingAddress = false),
                child: const Text('Use saved',
                    style: TextStyle(color: AppColors.neonCyan)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(Cart cart, bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title} x${item.quantity}',
                        style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(PriceFormatter.format(item.totalPrice),
                        style: TextStyle(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              )),
          Divider(color: AppColors.glassBorder(isDark), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal',
                  style: TextStyle(color: AppColors.textSecondary(isDark))),
              Text(PriceFormatter.format(cart.totalPrice),
                  style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Cart cart, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
            top: BorderSide(color: AppColors.glassBorder(isDark), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: AppColors.textSecondary(isDark), fontSize: 15)),
              Text(PriceFormatter.format(cart.totalPrice),
                  style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              final loading = state is OrderLoading;
              return GestureDetector(
                onTap: loading ? null : _processCheckout,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.neonCyan, AppColors.neonPurple],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.35),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('PLACE ORDER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 15,
                            )),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _GlassCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder(isDark), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;

  const _SectionLabel(
      {required this.icon, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.neonCyan),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            )),
      ],
    );
  }
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final TextInputType type;

  const _CheckoutField(this.controller, this.label, this.isDark,
      {this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 14),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: AppColors.textSecondary(isDark), fontSize: 13),
          filled: true,
          fillColor:
              isDark ? Colors.white.withOpacity(0.05) : AppColors.lightCardAlt,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder(isDark))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder(isDark))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.neonCyan, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.value,
    required this.title,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonCyan.withOpacity(isDark ? 0.1 : 0.08)
              : AppColors.glassFill(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected ? AppColors.neonCyan : AppColors.glassBorder(isDark),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.2),
                      blurRadius: 14)
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.neonCyan.withOpacity(0.15)
                    : AppColors.glassFill(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected
                      ? AppColors.neonCyan
                      : AppColors.textMuted(isDark),
                  size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    color: selected
                        ? AppColors.neonCyan
                        : AppColors.textPrimary(isDark),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  )),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.neonCyan, size: 20),
          ],
        ),
      ),
    );
  }
}
