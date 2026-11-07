import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

/// Photo picker area showing either a newly picked file, an existing remote
/// image, or an "add photo" placeholder.
class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    this.pickedImage,
    this.imageUrl,
    required this.onAdd,
    required this.onRemove,
  });

  final XFile? pickedImage;
  final String? imageUrl;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  bool get _hasPicked => pickedImage != null;
  bool get _hasRemote => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasPicked && !_hasRemote) {
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
          child: _hasPicked
              ? Image.file(
                  File(pickedImage!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _previewError(),
                )
              : Image.network(
                  imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _previewError(),
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

  Widget _previewError() {
    return Container(
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
    );
  }
}
