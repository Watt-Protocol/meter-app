import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/user_meter.dart';
import '../../../data/providers/meters_providers.dart';

Future<void> showAddMeterSheet(BuildContext context, WidgetRef ref) async {
  final labelController = TextEditingController();
  final deviceIdController = TextEditingController();
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.cardBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.lg,
          right: AppDimensions.lg,
          top: AppDimensions.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.lg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Meter',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppDimensions.lg),
              TextFormField(
                controller: labelController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g. Shop, Office',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Label required' : null,
              ),
              const SizedBox(height: AppDimensions.md),
              TextFormField(
                controller: deviceIdController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Meter code',
                  hintText: 'e.g. home-002',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Meter code required' : null,
              ),
              const SizedBox(height: AppDimensions.md),
              TextFormField(
                controller: locationController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g. Main Floor',
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('Save to account'),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (saved != true) {
    labelController.dispose();
    deviceIdController.dispose();
    locationController.dispose();
    return;
  }

  final ok = await addUserMeter(
    ref,
    label: labelController.text.trim(),
    deviceId: deviceIdController.text.trim(),
    location: locationController.text.trim().isEmpty
        ? null
        : locationController.text.trim(),
  );

  labelController.dispose();
  deviceIdController.dispose();
  locationController.dispose();

  if (context.mounted && !ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save meter. Run migration 003_user_meters.sql'),
        backgroundColor: AppColors.offline,
      ),
    );
  }
}

/// Opens add sheet and returns the created meter fields if saved.
Future<UserMeter?> showAddMeterSheetAndReturn(
  BuildContext context,
  WidgetRef ref,
) async {
  await showAddMeterSheet(context, ref);
  final meters = await ref.read(userMetersProvider.future);
  return meters.isNotEmpty ? meters.last : null;
}
