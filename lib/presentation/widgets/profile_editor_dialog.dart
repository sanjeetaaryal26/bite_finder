import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';

class ProfileEditorDialog extends StatefulWidget {
  final UserModel user;
  final Future<bool> Function({
    required String name,
    required String email,
    String? photoPath,
    bool removePhoto,
  }) onSave;

  const ProfileEditorDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<ProfileEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String? _photoPath;
  bool _removePhoto = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _email = TextEditingController(text: widget.user.email);
    _photoPath = widget.user.photoPath;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final selected = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 86,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _photoPath = selected.path;
      _removePhoto = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final ok = await widget.onSave(
      name: _name.text.trim(),
      email: _email.text.trim(),
      photoPath: _photoPath,
      removePhoto: _removePhoto,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  ImageProvider<Object>? _photoProvider() {
    final path = _photoPath?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _photoProvider();
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: imageProvider,
                child: imageProvider == null ? const Icon(Icons.person, size: 42) : null,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Change Photo'),
                  ),
                  if (_photoPath != null && _photoPath!.trim().isNotEmpty)
                    TextButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _photoPath = null;
                                _removePhoto = true;
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  final required = Validators.requiredField(value, fieldName: 'Name');
                  return required ?? Validators.minLength(value, 2, fieldName: 'Name');
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
