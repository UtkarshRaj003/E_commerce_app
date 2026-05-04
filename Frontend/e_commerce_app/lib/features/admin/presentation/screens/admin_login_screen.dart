import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Colors for Admin Console Theme
  final Color _slateDark = const Color(0xFF0F172A);
  final Color _cardColor = const Color(0xFF1E293B);
  final Color _accentColor = Colors.purpleAccent;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminBloc>().add(
            AdminLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slateDark,
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else if (state is AdminError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        child: Stack(
          children: [
            // Background Decorative Circles (Admin Style)
            Positioned(
              top: -100,
              right: -50,
              child: CircleAvatar(
                  radius: 150, backgroundColor: _accentColor.withOpacity(0.05)),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: AnimationLimiter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          // Admin Icon with Glassmorphism
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Icon(Icons.admin_panel_settings_rounded,
                                  size: 80, color: _accentColor),
                            ),
                          ),
                          const SizedBox(height: 30),

                          const Text(
                            'ADMIN CONSOLE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Access secure management tools',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16),
                          ),
                          const SizedBox(height: 50),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Admin Email',
                            icon: Icons.alternate_email_rounded,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Email is required'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Security Key',
                            icon: Icons.lock_person_rounded,
                            isPassword: true,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Password is required'
                                : null,
                          ),
                          const SizedBox(height: 40),

                          // Login Button
                          BlocBuilder<AdminBloc, AdminState>(
                            builder: (context, state) {
                              final isLoading = state is AdminLoginLoading;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 58),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  elevation: 10,
                                  shadowColor: _accentColor.withOpacity(0.5),
                                ),
                                onPressed: isLoading ? null : _login,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Text(
                                        'AUTHENTICATE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: _accentColor, size: 22),
        filled: true,
        fillColor: _cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: _accentColor.withOpacity(0.5), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
