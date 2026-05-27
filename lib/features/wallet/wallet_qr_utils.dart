import '../../core/config/supabase_config.dart';

/// Parse Ethereum address from raw text or `ethereum:0x…` QR payloads.
String? parseAddressFromQr(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  var value = trimmed;
  if (value.toLowerCase().startsWith('ethereum:')) {
    value = value.substring('ethereum:'.length);
  }
  final queryIndex = value.indexOf('?');
  if (queryIndex >= 0) {
    value = value.substring(0, queryIndex);
  }
  value = value.trim();

  final match = RegExp(r'0x[a-fA-F0-9]{40}').firstMatch(value);
  return match?.group(0);
}

bool isValidEthAddress(String? address) {
  if (address == null) return false;
  return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
}

/// MetaMask universal link (user selects WATT token in wallet).
Uri metamaskSendLink({
  required String toAddress,
  String? amount,
}) {
  final base = 'https://metamask.app.link/send/$toAddress@${SupabaseConfig.chainId}';
  if (amount != null && amount.isNotEmpty) {
    return Uri.parse('$base?uint256=$amount');
  }
  return Uri.parse(base);
}

String buildTransferDetails({
  required String toAddress,
  String? amountWatt,
}) {
  final amountLine = amountWatt != null && amountWatt.isNotEmpty
      ? 'Amount: $amountWatt WATT\n'
      : '';
  return '${amountLine}To: $toAddress\n'
      'WATT token on Base testnet\n'
      'Contract: ${SupabaseConfig.wattContractAddress}';
}
