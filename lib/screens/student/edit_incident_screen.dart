import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/incident_style.dart';
import '../../utils/validators.dart';
import '../../widgets/photo_field.dart';

/// Lets a student edit a report they submitted while it is still submitted.
class EditIncidentScreen extends StatefulWidget {
  const EditIncidentScreen({super.key, required this.incident});

  final Incident incident;

  @override
  State<EditIncidentScreen> createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _customLocationController = TextEditingController();

  late IncidentCategory _category;
  String? _location;
  bool _saving = false;
  XFile? _newPhoto;
  bool _removeExistingPhoto = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.incident.title);
    _descriptionController = TextEditingController(
      text: widget.incident.description,
    );
    _category = widget.incident.category;

    final existingLocation = widget.incident.location;
    if (existingLocation != null && existingLocation.trim().isNotEmpty) {
      if (_locations.contains(existingLocation) &&
          existingLocation != 'Other') {
        _location = existingLocation;
      } else {
        _location = 'Other';
        _customLocationController.text = existingLocation;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customLocationController.dispose();
    super.dispose();
  }

  String? _resolvedLocation() {
    if (_location == null) return null;
    if (_location == 'Other') {
      final custom = _customLocationController.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _location;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file != null && mounted) {
        setState(() {
          _newPhoto = file;
          _removeExistingPhoto = false;
        });
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

  void _removePhoto() {
    setState(() {
      if (_newPhoto != null) {
        _newPhoto = null;
      } else {
        _removeExistingPhoto = true;
      }
    });
  }

  String? get _visibleImageUrl =>
      _removeExistingPhoto ? null : widget.incident.imageUrl;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<IncidentProvider>();
    setState(() => _saving = true);

    String? imageUrl = _visibleImageUrl;
    if (_newPhoto != null) {
      final bytes = await _newPhoto!.readAsBytes();
      imageUrl = await provider.uploadImage(
        bytes: bytes,
        filename: _newPhoto!.name,
      );
      if (!mounted) return;
      if (imageUrl == null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not upload the photo. Please try again.'),
          ),
        );
        return;
      }
    }

    final updated = await provider.updateIncident(
      incident: widget.incident,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      imageUrl: imageUrl,
      location: _resolvedLocation(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (updated != null) {
      Navigator.of(context).pop(updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update the report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              PhotoField(
                pickedImage: _newPhoto,
                imageUrl: _visibleImageUrl,
                onAdd: _showPhotoOptions,
                onRemove: _removePhoto,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save changes'),
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
