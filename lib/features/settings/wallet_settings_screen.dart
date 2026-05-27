import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/supabase_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/sensor_providers.dart';
import '../../routing/app_router.dart';
import '../../routing/tab_navigation_provider.dart';
import '../dashboard/widgets/total_rewards_card.dart';
import 'widgets/wallet_rewards_card.dart';
import 'widgets/settings_section_header.dart';

/// Wallet address, send/receive, payouts, and explorer.
class WalletSettingsScreen extends ConsumerWidget {
  const WalletSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBg
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.walletSettingsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          0,
          AppDimensions.md,
          AppDimensions.xl,
        ),
        children: [
          profileAsync.when(
            loading: () => const TotalRewardsCard(isLoading: true),
            error: (_, _) => const TotalRewardsCard(),
            data: (profile) => TotalRewardsCard(profile: profile),
          ),
          const SizedBox(height: AppDimensions.lg),
          const SettingsSectionHeader(title: AppStrings.connectedWallet),
          profileAsync.when(
            loading: () => WalletRewardsCard(
              onPayouts: () => _goHistory(context, ref),
              onExplorer: () {},
              onEditWallet: () => _editWallet(context, ref),
            ),
            error: (_, _) => WalletRewardsCard(
              onPayouts: () => _goHistory(context, ref),
              onExplorer: () {},
              onEditWallet: () => _editWallet(context, ref),
            ),
            data: (profile) => WalletRewardsCard(
              walletAddress: profile?.walletAddress,
              onPayouts: () => _goHistory(context, ref),
              onExplorer: () => _openExplorer(profile?.walletAddress),
              onEditWallet: () =>
                  _editWallet(context, ref, profile?.walletAddress),
            ),
          ),
        ],
      ),
    );
  }

  void _goHistory(BuildContext context, WidgetRef ref) {
    ref.read(tabNavigationProvider.notifier).setIndices(2, 1);
    context.go(AppRoutes.history);
  }

  bool _isValidWallet(String value) {
    final v = value.trim();
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v);
  }

  Future<void> _editWallet(
    BuildContext context,
    WidgetRef ref, [
    String? current,
  ]) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final controller = TextEditingController(text: current ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.editWallet),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: AppStrings.walletAddressHint,
          ),
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );

    if (saved != true || !context.mounted) return;

    final addr = controller.text.trim();
    if (addr.isNotEmpty && !_isValidWallet(addr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.invalidWallet)),
      );
      return;
    }

    final ok = await ref.read(userProfileRepositoryProvider).updateWallet(
          userId,
          addr.isEmpty ? null : addr,
        );
    if (!context.mounted) return;

    if (ok) {
      ref.invalidate(userProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.walletSaved),
          backgroundColor: AppColors.gold,
        ),
      );
    }
  }

  Future<void> _openExplorer(String? address) async {
    if (address == null || address.isEmpty) return;
    final url = Uri.parse('${SupabaseConfig.explorerBaseUrl}$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
