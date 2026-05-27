import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'wallet_qr_utils.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _showScanner = false;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final address = parseAddressFromQr(raw);
      if (address != null) {
        setState(() {
          _addressController.text = address;
          _showScanner = false;
        });
        return;
      }
    }
  }

  Future<void> _openWallet() async {
    final address = _addressController.text.trim();
    if (!isValidEthAddress(address)) {
      _showMessage(AppStrings.invalidAddress);
      return;
    }
    final amount = _amountController.text.trim();
    final uri = metamaskSendLink(
      toAddress: address,
      amount: amount.isEmpty ? null : amount,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage(AppStrings.connectionError);
    }
  }

  void _copyDetails() {
    final address = _addressController.text.trim();
    if (!isValidEthAddress(address)) {
      _showMessage(AppStrings.invalidAddress);
      return;
    }
    final details = buildTransferDetails(
      toAddress: address,
      amountWatt: _amountController.text.trim(),
    );
    Clipboard.setData(ClipboardData(text: details));
    _showMessage(AppStrings.copied);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.gold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.sendWatt),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showScanner) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: SizedBox(
                  height: 260,
                  child: MobileScanner(onDetect: _onQrDetected),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextButton(
                onPressed: () => setState(() => _showScanner = false),
                child: Text(AppStrings.cancel),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
            OutlinedButton.icon(
              onPressed: () => setState(() => _showScanner = !_showScanner),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(AppStrings.scanQr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            TextField(
              controller: _addressController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: AppStrings.recipientAddress,
                hintText: '0x…',
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: AppStrings.amountWatt,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton.icon(
              onPressed: _openWallet,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text(AppStrings.openInWallet),
            ),
            const SizedBox(height: AppDimensions.md),
            OutlinedButton.icon(
              onPressed: _copyDetails,
              icon: const Icon(Icons.copy_rounded),
              label: Text(AppStrings.copyTransferDetails),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.inputBorder),
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
