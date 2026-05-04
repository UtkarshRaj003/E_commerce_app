import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:e_commerce_app/features/admin/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // EXACT colors from your "Manage Categories" screenshot
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;

    context.read<AdminBloc>().add(AdminUsersLoadRequested());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Manage Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: titleColor,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminUsersLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (state is AdminUsersLoaded) {
            return AnimationLimiter(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: state.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildUserCard(context, user, cardColor, isDark),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, UserModel user, Color cardColor, bool isDark) {
    return GestureDetector(
      onTap: () => _showUserDetails(context, user, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
              BorderRadius.circular(28), // Matches Category card roundness
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar with white container background like Category Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: user.avatar != null && user.avatar!.isNotEmpty
                      ? AppImage(imageUrl: user.avatar!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Action Buttons matching Category Screen
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.chevron_right, color: Colors.blueAccent),
                  onPressed: () => _showUserDetails(context, user, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Details Modal ---
  void _showUserDetails(BuildContext context, UserModel user, bool isDark) {
    // Theme constants
    const Color bgDark = Color(0xFF0F172A);
    const Color cardColor = Color(0xFF1E293B);
    const Color greenAccent = Colors.greenAccent;

    // Address logic
    final bool hasAddress = user.addresses.isNotEmpty;
    final dynamic primaryAddr = hasAddress ? user.addresses.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: bgDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Drag Handle
            Positioned(
              top: 12,
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Header Section
                  Text(
                    user.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: greenAccent.withOpacity(0.2)),
                    ),
                    child: Text(
                      user.role.toUpperCase(), // e.g., ADMIN / CUSTOMER
                      style: const TextStyle(
                        color: greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Info Grid (Two columns for compact view)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailItem(Icons.alternate_email_rounded, "Email",
                            user.email, greenAccent),
                        const Divider(color: Colors.white10, height: 24),
                        _buildDetailItem(Icons.phone_android_rounded, "Phone",
                            user.phone ?? "Not Provided", greenAccent),
                        const Divider(color: Colors.white10, height: 24),
                        _buildDetailItem(
                            Icons.location_on_outlined,
                            "Primary Address",
                            hasAddress
                                ? "${primaryAddr['addressLine']}, ${primaryAddr['city']}"
                                : "No address set",
                            greenAccent),
                        const Divider(color: Colors.white10, height: 24),
                        _buildDetailItem(
                            Icons.calendar_today_rounded,
                            "Joined On",
                            DateFormat('dd MMMM yyyy').format(user.createdAt),
                            greenAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("DISMISS",
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // Action like Edit or View Orders
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenAccent,
                            foregroundColor: bgDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("VIEW ACTIVITY",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Overlapping Avatar
            Positioned(
              top: -45,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration:
                    const BoxDecoration(color: bgDark, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: cardColor,
                  child: user.avatar != null && user.avatar!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: AppImage(
                              imageUrl: user.avatar!, width: 90, height: 90),
                        )
                      : Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 32,
                              color: greenAccent,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
