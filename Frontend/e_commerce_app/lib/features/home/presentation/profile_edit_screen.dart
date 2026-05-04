import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/common/widgets/common_widgets.dart';
import 'package:e_commerce_app/features/auth/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Theme Constants
  static const Color primaryNeon = Color(0xFF00FFC2);
  static const Color bgDark = Color(0xFF0A0E12);
  static const Color cardDark = Color(0xFF161B22);

  File? _image;
  String? existingImage;
  String? existingAddressId;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final repo = context.read<UserRepository>();
      final user = await repo.getProfile();

      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      existingImage = user.avatar;

      if (user.addresses.isNotEmpty) {
        final addr = user.addresses.first;
        existingAddressId = addr.id;
        _addressLineController.text = addr.addressLine;
        _cityController.text = addr.city;
        _stateController.text = addr.state;
        _pincodeController.text = addr.pincode;
      }
    } catch (e) {
      _showStatus('Failed to load profile', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    final repo = context.read<UserRepository>();
    try {
      await repo.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

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

      if (_image != null) {
        await repo.uploadAvatar(_image!);
        if (existingImage != null) {
          await CachedNetworkImage.evictFromCache(
              getFullImageUrl(existingImage!));
        }
      }

      if (mounted) {
        _showStatus('Profile Synchronized!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showStatus(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showStatus(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : primaryNeon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: bgDark,
          body: Center(child: CircularProgressIndicator(color: primaryNeon)));
    }

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text('EDIT PROFILE',
            style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNeonAvatar(),
                  const SizedBox(height: 40),
                  _buildSectionLabel(
                      "Personal Information", Icons.person_outlined),
                  _buildGlassCard([
                    _buildNeonField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.badge_outlined,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildNeonField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 30),
                  _buildSectionLabel(
                      "Shipping Address", Icons.location_on_outlined),
                  _buildGlassCard([
                    _buildNeonField(
                      controller: _addressLineController,
                      label: "Address Line",
                      icon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNeonField(
                                controller: _cityController, label: "City")),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildNeonField(
                                controller: _stateController, label: "State")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildNeonField(
                      controller: _pincodeController,
                      label: "Pincode",
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildNeonSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: primaryNeon.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glow
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: const Color.fromARGB(255, 0, 255, 251)
                          .withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5)
                ],
              ),
            ),
            // Avatar Border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 255, 251),
                  shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: cardDark,
                child: AppImage(
                  file: _image,
                  imageUrl: existingImage,
                  width: 116,
                  height: 116,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
            // Camera Icon
            Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 255, 251), shape: BoxShape.circle),
                child:
                    const Icon(Icons.camera_alt, size: 20, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNeonField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: primaryNeon.withOpacity(0.5), size: 20)
            : null,
        filled: true,
        fillColor: bgDark.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryNeon, width: 1)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildNeonSaveButton() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: primaryNeon.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: ElevatedButton(
          onPressed: isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 251, 255),
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: isSaving
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text("SAVE CHANGES",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }
}
