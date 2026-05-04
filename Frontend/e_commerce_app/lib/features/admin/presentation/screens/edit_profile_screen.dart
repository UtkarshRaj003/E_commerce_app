import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/widgets/common_widgets.dart';
import '../../../auth/data/repositories/user_repository.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  File? _image;
  String? existingImage;
  String? existingAddressId;
  bool isLoading = true;
  bool isSaving = false;

  // Controls the slide-up entry animation of the form
  AnimationController? _entryController;
  Animation<double> _entryFade = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade =
        CurvedAnimation(parent: _entryController!, curve: Curves.easeOut);
    _loadAdminData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _entryController?.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    try {
      final repo = context.read<UserRepository>();
      final admin = await repo.getProfile();

      _nameController.text = admin.name;
      _phoneController.text = admin.phone ?? '';
      existingImage = admin.avatar;

      if (admin.addresses.isNotEmpty) {
        final addr = admin.addresses.first;
        existingAddressId = addr.id;
        _addressLineController.text = addr.addressLine;
        _cityController.text = addr.city;
        _stateController.text = addr.state;
        _pincodeController.text = addr.pincode;
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to load profile: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        _entryController?.forward();
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    final repo = context.read<UserRepository>();

    try {
      // Step 1: Update name and phone
      await repo.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Step 2: Update or add address depending on whether one exists
      if (existingAddressId != null) {
        await repo.updateAddress(
          id: existingAddressId!,
          addressLine: _addressLineController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
        );
      } else {
        await repo.addAddress(
          addressLine: _addressLineController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
        );
      }

      // Step 3: Upload new avatar only if one was picked
      if (_image != null) {
        await repo.uploadAvatar(_image!);
        // Evict old cached avatar so the new one shows immediately
        if (existingImage != null) {
          await CachedNetworkImage.evictFromCache(
              getFullImageUrl(existingImage!));
        }
      }

      if (mounted) {
        showAppSnackBar(context, 'Profile updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.deepSpace
          : const Color.fromARGB(255, 255, 255, 255),
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color(0xFF0A0E1A),
                    Color(0xFF0D1F3C),
                    Color(0xFF0A0E1A),
                  ]
                : [
                    Color.fromARGB(255, 255, 255, 255), // pure white
                    Color.fromARGB(255, 157, 206, 255), // soft bluish grey
                    Color.fromARGB(255, 156, 145, 255),
                  ],
          ),
        ),
        child: isLoading
            ? const Center(child: LoadingWidget(message: 'Loading profile...'))
            : FadeTransition(
                opacity: _entryFade,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
                  children: [
                    // Avatar section — tap to pick from gallery
                    _buildAvatarSection(),

                    const SizedBox(height: 28),

                    // Personal info card
                    _buildGlassSection(
                      title: 'Personal Info',
                      icon: Icons.admin_panel_settings_outlined,
                      accentColor: AppColors.neonCyan,
                      child: Column(
                        children: [
                          _AdminField(
                            controller: _nameController,
                            label: 'Admin Name',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          _AdminField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Address card
                    _buildGlassSection(
                      title: 'Address',
                      icon: Icons.location_on_outlined,
                      accentColor: AppColors.neonPurple,
                      child: Column(
                        children: [
                          _AdminField(
                            controller: _addressLineController,
                            label: 'Office / Home Address',
                            icon: Icons.home_outlined,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _AdminField(
                                  controller: _cityController,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AdminField(
                                  controller: _stateController,
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _AdminField(
                            controller: _pincodeController,
                            label: 'Pincode',
                            icon: Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Save changes button
                    _buildSaveButton(),
                  ],
                ),
              ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? Colors.white : Colors.black87);

    final Color iconColor = isDark ? Colors.white70 : Colors.black54;

    final Color borderColor = isDark ? Colors.white : Colors.black;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF0A0E1A),
                        Color(0xFF0D1F3C),
                        Color(0xFF0A0E1A),
                      ]
                    : [
                        Color.fromARGB(255, 228, 232, 255), // pure white
                        Color.fromARGB(255, 174, 213, 252), // soft bluish grey
                        Color.fromARGB(255, 183, 175, 255),
                      ],
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
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Edit Admin Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    // Shield badge marking this as the admin area
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.neonPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.neonPurple.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPurple.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded,
                              size: 12, color: AppColors.neonPurple),
                          SizedBox(width: 4),
                          Text(
                            'ADMIN',
                            style: TextStyle(
                              color: AppColors.neonPurple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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

  // ─── Avatar ───────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            // Glowing neon ring around the avatar
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.neonCyan, AppColors.neonPurple],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: _image != null
                    // Local file picked from gallery
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : AppImage(
                        imageUrl: existingImage,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            // Camera overlay badge at bottom-right
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonPurple],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.deepSpace,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section card ─────────────────────────────────────────────────────────────

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header with colored icon badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentColor.withOpacity(1)),
                    ),
                    child: Icon(icon, color: accentColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Save button ──────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: isSaving ? null : _saveProfile,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.neonCyan, AppColors.neonPurple],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Update Admin Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Admin form field ─────────────────────────────────────────────────────────
// Glass-styled text field matching the product edit form's look.
class _AdminField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _AdminField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
      ),
    );
  }
}
