import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Shows a delete confirmation dialog.
/// Returns true if the user confirmed, false otherwise.
Future<bool> showConfirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.delete, size: 15),
          label: Text(AppStrings.delete),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A three-dot overflow menu with Edit and Delete actions.
/// Place this in the app-bar / header row of a detail screen.
class EditDeleteMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const EditDeleteMenu(
      {super.key, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (a) {
        if (a == _Action.edit) onEdit();
        if (a == _Action.delete) onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _Action.edit,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(AppStrings.edit, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Action.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
              const SizedBox(width: 10),
              Text(AppStrings.delete,
                  style: const TextStyle(fontSize: 13, color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Action { edit, delete }
