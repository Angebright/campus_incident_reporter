import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/incident_category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/incident_style.dart';
import '../../utils/validators.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  static const List<String> _locations = [
    'Library',
    'Hostel',
    'Lecture Hall',
    'Cafeteria',
    'Science Block',
    'Sports Complex',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customLocationController = TextEditingController();

  IncidentCategory _category = IncidentCategory.facilities;
  String? _location;
  XFile? _pickedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file != null && mounted) {
        setState(() => _pickedImage = file);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access the photo picker.')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? _resolvedLocation() {
    if (_location == null) return null;
    if (_location == 'Other') {
      final custom = _customLocationController.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _location;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final reporter = context.read<AuthProvider>().user;
    if (reporter == null) return;

    setState(() => _submitting = true);
    final success = await context.read<IncidentProvider>().submitIncident(
          reporter: reporter,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          location: _resolvedLocation(),
          imageUrl: null,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      _resetForm();
      context.read<NavigationProvider>().setIndex(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit your report. Please try again.'),
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _customLocationController.clear();
    setState(() {
      _category = IncidentCategory.facilities;
      _location = null;
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Report an issue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tell us what needs attention on campus.',
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Category'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.4,
                children: [
                  for (final category in IncidentCategory.values)
                    _CategoryTile(
                      category: category,
                      selected: _category == category,
                      onTap: () => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Details'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, 'Title'),
                decoration: const InputDecoration(hintText: 'Report title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) => Validators.required(value, 'Description'),
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),
              const _FieldLabel('Location'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                initialValue: _location,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select a location',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Not specified'),
                  ),
                  for (final location in _locations)
                    DropdownMenuItem<String?>(
                      value: location,
                      child: Text(location),
                    ),
                ],
                onChanged: (value) => setState(() => _location = value),
              ),
              if (_location == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customLocationController,
                  decoration: const InputDecoration(
                    hintText: 'Enter the location',
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const _FieldLabel('Photo (optional)'),
              const SizedBox(height: 10),
              _PhotoField(
                pickedImage: _pickedImage,
                onAdd: _showPhotoOptions,
                onRemove: () => setState(() => _pickedImage = null),
              ),
              const SizedBox(height: 8),
              const Text(
                'Photos are previewed only and are not uploaded in this build.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(categoryIcon(category), size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? color : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.pickedImage,
    required this.onAdd,
    required this.onRemove,
  });

  final XFile? pickedImage;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (pickedImage == null) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              SizedBox(height: 8),
              Text(
                'Add a photo',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: Image.file(
            File(pickedImage!.path),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'Preview unavailable',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}
