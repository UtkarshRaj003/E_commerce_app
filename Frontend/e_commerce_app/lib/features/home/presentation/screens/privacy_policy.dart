// import 'package:flutter/material.dart';

// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Privacy Policy")),
//       body: const Padding(
//         padding: EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Text(
//             '''
// We respect your privacy.

// 1. We collect basic user info like name, email, phone.
// 2. We use it only for order processing and communication.
// 3. We do not sell or share your data.
// 4. Payments are processed securely via Razorpay.
// 5. You can request account deletion anytime.

// By using our app, you agree to this policy.
//             ''',
//             style: TextStyle(fontSize: 14),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../common/widgets/common_widgets.dart';

// Shared layout widget for both Privacy Policy and Terms & Conditions screens.
// Uses glassmorphism cards and futuristic typography for a polished look.
class _LegalScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_LegalSection> sections;
  final Color accentColor;

  const _LegalScreen({
    required this.title,
    required this.icon,
    required this.sections,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF0D1F3C),
              Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 40),
          children: [
            // Hero card with icon and screen title
            _buildHeroCard(icon, title, accentColor),
            const SizedBox(height: 24),
            // Each section rendered as a separate glass card
            ...sections.asMap().entries.map(
                  (entry) => _AnimatedSectionCard(
                    index: entry.key,
                    section: entry.value,
                    accentColor: accentColor,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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

  Widget _buildHeroCard(IconData icon, String title, Color accent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withOpacity(0.15),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please read carefully',
                      style: TextStyle(
                        color: accent.withOpacity(0.8),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A single legal section with a number badge, title, and description.
class _LegalSection {
  final String title;
  final String body;

  const _LegalSection({required this.title, required this.body});
}

// Animates each legal section card with a staggered slide-up entrance.
class _AnimatedSectionCard extends StatefulWidget {
  final int index;
  final _LegalSection section;
  final Color accentColor;

  const _AnimatedSectionCard({
    required this.index,
    required this.section,
    required this.accentColor,
  });

  @override
  State<_AnimatedSectionCard> createState() => _AnimatedSectionCardState();
}

class _AnimatedSectionCardState extends State<_AnimatedSectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
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
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.07),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numbered badge for each section
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.accentColor,
                            widget.accentColor.withOpacity(0.6),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.section.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.section.body,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              height: 1.5,
                            ),
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

// Privacy Policy screen using the shared _LegalScreen layout.
// Sections cover data collection, usage, security, and user rights.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScreen(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_rounded,
      accentColor: AppColors.neonCyan,
      sections: const [
        _LegalSection(
          title: 'Data Collection',
          body:
              'We collect basic user information like name, email, and phone number to provide you with the best shopping experience.',
        ),
        _LegalSection(
          title: 'How We Use Your Data',
          body:
              'Your data is used solely for order processing, delivery communication, and improving our services.',
        ),
        _LegalSection(
          title: 'Data Sharing',
          body:
              'We do not sell or share your personal data with third parties for marketing purposes.',
        ),
        _LegalSection(
          title: 'Payment Security',
          body:
              'All payment transactions are processed securely through Razorpay with industry-standard encryption.',
        ),
        _LegalSection(
          title: 'Your Rights',
          body:
              'You can request account deletion or data export at any time by contacting our support team.',
        ),
        _LegalSection(
          title: 'Policy Agreement',
          body:
              'By using our app, you agree to this privacy policy. We may update this policy periodically and will notify you of changes.',
        ),
      ],
    );
  }
}

// Terms & Conditions screen using the shared _LegalScreen layout.
// Covers ordering, returns, payments, and account policies.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScreen(
      title: 'Terms & Conditions',
      icon: Icons.description_rounded,
      accentColor: AppColors.neonPurple,
      sections: const [
        _LegalSection(
          title: 'Order Cancellation',
          body:
              'Orders placed cannot be cancelled once they have been shipped. Please review your order carefully before confirming.',
        ),
        _LegalSection(
          title: 'Cash on Delivery',
          body:
              'COD is available on selected orders based on delivery location and order value. Additional charges may apply.',
        ),
        _LegalSection(
          title: 'Return Policy',
          body:
              'Items can be returned within 7 days of delivery in original condition. Damaged or used items are not eligible for return.',
        ),
        _LegalSection(
          title: 'Account Usage',
          body:
              'Misuse of the app including fraudulent orders or abusive behavior may lead to permanent account suspension.',
        ),
        _LegalSection(
          title: 'Intellectual Property',
          body:
              'All content within this app including designs, text, and images are owned by us and protected under applicable laws.',
        ),
        _LegalSection(
          title: 'Terms Updates',
          body:
              'We reserve the right to update these terms at any time. Continued use of the app after changes constitutes your acceptance.',
        ),
      ],
    );
  }
}
