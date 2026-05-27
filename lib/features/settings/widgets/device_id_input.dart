import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/providers/settings_providers.dart';

/// Text field for editing the device ID.
class DeviceIdInput extends ConsumerStatefulWidget {
  const DeviceIdInput({super.key});

  @override
  ConsumerState<DeviceIdInput> createState() => _DeviceIdInputState();
}

class _DeviceIdInputState extends ConsumerState<DeviceIdInput> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final currentId = ref.read(deviceIdProvider);
    _controller = TextEditingController(text: currentId);
    _controller.addListener(() {
      final changed = _controller.text != ref.read(deviceIdProvider);
      if (changed != _hasChanges) {
        setState(() => _hasChanges = changed);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final newId = _controller.text.trim();
    if (newId.isNotEmpty) {
      ref.read(deviceIdProvider.notifier).setDeviceId(newId);
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.meterCodeSaved}: $newId'),
          backgroundColor: AppColors.gold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: AppStrings.meterCode,
              prefixIcon: Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        if (_hasChanges) ...[
          const SizedBox(width: AppDimensions.sm),
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_rounded),
            color: AppColors.gold,
            tooltip: 'Save',
          ),
        ],
      ],
    );
  }
}
