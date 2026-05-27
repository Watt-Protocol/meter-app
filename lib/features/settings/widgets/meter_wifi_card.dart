import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/wifi_providers.dart';
import 'settings_section_header.dart';

/// Lets the producer see and update the Wi‑Fi network the meter should use.
class MeterWifiCard extends ConsumerStatefulWidget {
  const MeterWifiCard({super.key});

  @override
  ConsumerState<MeterWifiCard> createState() => _MeterWifiCardState();
}

class _MeterWifiCardState extends ConsumerState<MeterWifiCard> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _saving = false;
  String? _loadedSsid;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyLoaded(String? ssid, String? password) {
    if (_loadedSsid == ssid) return;
    _loadedSsid = ssid;
    if (ssid != null && _ssidController.text.isEmpty) {
      _ssidController.text = ssid;
    }
    if (password != null &&
        password.isNotEmpty &&
        _passwordController.text.isEmpty) {
      _passwordController.text = password;
    }
  }

  Future<void> _save() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;
    if (ssid.isEmpty) {
      _showMessage(AppStrings.wifiNetworkNameRequired);
      return;
    }
    if (password.isEmpty) {
      _showMessage(AppStrings.wifiPasswordRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(wifiConfigRepositoryProvider).saveNetwork(
            ssid: ssid,
            password: password,
          );
      ref.invalidate(meterWifiProvider);
      _loadedSsid = ssid;
      _ssidController.text = ssid;
      _passwordController.text = password;
      if (!mounted) return;
      _showMessage(AppStrings.wifiSaved);
    } catch (e) {
      if (!mounted) return;
      _showMessage(AppStrings.wifiSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.gold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wifiAsync = ref.watch(meterWifiProvider);

    return wifiAsync.when(
      loading: () => SettingsCard(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Center(
            child: Text(
              AppStrings.loadingWifi,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
        ),
      ),
      error: (_, __) => SettingsCard(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Text(
            AppStrings.wifiLoadFailed,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ),
      ),
      data: (wifi) {
        _applyLoaded(wifi?.ssid, wifi?.password);
        final updatedLabel = wifi?.updatedAt != null
            ? DateFormat('MMM d, HH:mm').format(wifi!.updatedAt!.toLocal())
            : null;

        return SettingsCard(
          goldAccentBorder: true,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi_rounded,
                        color: AppColors.gold, size: 22),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        AppStrings.meterWifiTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  wifi == null
                      ? AppStrings.meterWifiEmptyHint
                      : AppStrings.meterWifiActiveHint(
                          wifi.ssid.isEmpty ? '—' : wifi.ssid,
                        ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                if (updatedLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.wifiLastUpdated} $updatedLabel',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.wifiNetworkName,
                    prefixIcon: Icon(Icons.router_rounded,
                        color: AppColors.textMuted),
                  ),
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                ),
                const SizedBox(height: AppDimensions.sm),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.wifiPassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  autocorrect: false,
                ),
                const SizedBox(height: AppDimensions.md),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.scaffoldBg,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppStrings.saveWifiForMeter),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
