import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';

const _languages = ['English', 'Kinyarwanda', 'French'];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late String _language;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    final accountName = context.read<AuthBloc>().state.user?.name ?? '';
    _nameController = TextEditingController(
      text: profile.displayName.isNotEmpty ? profile.displayName : accountName,
    );
    _bioController = TextEditingController(text: profile.bio);
    _phoneController = TextEditingController(text: profile.phone);
    _locationController = TextEditingController(text: profile.location);
    _language = profile.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      context.read<ProfileBloc>().add(ProfileAvatarPicked(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not open the camera or gallery.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfileSaved(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        language: _language,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.profile.avatarPath != current.profile.avatarPath,
        builder: (context, state) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: state.profile.hasAvatar
                              ? FileImage(File(state.profile.avatarPath))
                              : null,
                          child: state.profile.hasAvatar
                              ? null
                              : const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: Colors.white,
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell other travellers a bit about yourself',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.edit_note_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Home city (optional)',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final lang in _languages)
                        ChoiceChip(
                          label: Text(lang),
                          selected: _language == lang,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _language == lang
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (_) => setState(() => _language = lang),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
