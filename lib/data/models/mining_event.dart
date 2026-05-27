/// A row from `mining_events` (one mint = user transfer + CIF transfer legs).
class MiningEvent {
  final int id;
  final double kwh;
  /// Gross WATT (1 kWh = 1 WATT) before 85/15 split.
  final double wattGross;
  final double userAmount;
  final double cifAmount;
  final String status;
  final String userTxStatus;
  final String cifTxStatus;
  final String? txHash;
  final String? cifTxHash;
  final DateTime createdAt;

  const MiningEvent({
    required this.id,
    required this.kwh,
    required this.wattGross,
    required this.userAmount,
    required this.cifAmount,
    required this.status,
    required this.userTxStatus,
    required this.cifTxStatus,
    this.txHash,
    this.cifTxHash,
    required this.createdAt,
  });

  factory MiningEvent.fromJson(Map<String, dynamic> json) {
    final gross = _parseDouble(json['watt_gross'] ?? json['watt_earned']);
    final txHash = _nonEmptyString(json['tx_hash']);
    final status = json['status']?.toString() ?? 'pending';
    return MiningEvent(
      id: json['id'] as int,
      kwh: _parseDouble(json['kwh']),
      wattGross: gross,
      userAmount: _parseDouble(json['user_amount']),
      cifAmount: _parseDouble(json['cif_amount']),
      status: status,
      userTxStatus: _resolveUserTxStatus(json, status: status, txHash: txHash),
      cifTxStatus: _resolveCifTxStatus(json, txHash: txHash),
      txHash: txHash,
      cifTxHash: _nonEmptyString(json['cif_tx_hash']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// User wallet received WATT (matches one incoming chain tx when confirmed).
  double get userWattReceived =>
      userAmount > 0 ? userAmount : wattGross * 0.85;

  bool get isUserTransferConfirmed {
    if (isFailed) return false;
    if (userTxStatus.toLowerCase() == 'confirmed') return true;
    if (txHash != null && txHash!.isNotEmpty) return true;
    final s = status.toLowerCase();
    if (s == 'confirmed' ||
        s == 'completed' ||
        s == 'success' ||
        s == 'credited') {
      return userAmount > 0 || txHash != null;
    }
    return false;
  }

  bool get isCifTransferConfirmed =>
      cifTxStatus.toLowerCase() == 'confirmed' &&
      cifTxHash != null &&
      cifTxHash!.isNotEmpty;

  bool get isFailed =>
      userTxStatus.toLowerCase() == 'failed' ||
      status.toLowerCase() == 'failed';

  bool get isPending =>
      !isFailed && !isUserTransferConfirmed;

  /// Confirmed user payout (one wallet tx).
  bool get isConfirmed => isUserTransferConfirmed;

  String get displayStatusLabel {
    if (isFailed) return 'Failed';
    if (isUserTransferConfirmed) return 'Confirmed';
    return 'Pending';
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String? _nonEmptyString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

String _resolveUserTxStatus(
  Map<String, dynamic> json, {
  required String status,
  required String? txHash,
}) {
  final raw = json['user_tx_status']?.toString();
  if (raw != null && raw.isNotEmpty) {
    final lower = raw.toLowerCase();
    if (lower == 'confirmed' || lower == 'failed') return lower;
  }
  if (txHash != null) return 'confirmed';
  final s = status.toLowerCase();
  if (s == 'confirmed' ||
      s == 'completed' ||
      s == 'success' ||
      s == 'credited') {
    return 'confirmed';
  }
  if (s == 'failed') return 'failed';
  return 'pending';
}

String _resolveCifTxStatus(Map<String, dynamic> json, {required String? txHash}) {
  final cifHash = _nonEmptyString(json['cif_tx_hash']);
  final raw = json['cif_tx_status']?.toString();
  if (raw != null && raw.isNotEmpty) return raw.toLowerCase();
  if (cifHash != null) return 'confirmed';
  if (txHash != null && _parseDouble(json['cif_amount']) < 0.001) return 'skipped';
  return 'pending';
}

/// Aggregated mining stats for a date range.
class MiningSummary {
  final double totalKwh;
  final double totalWattGross;
  final double totalUserWatt;
  final double totalCifAmount;
  final int countPending;
  final int countConfirmed;
  final int countFailed;

  const MiningSummary({
    required this.totalKwh,
    required this.totalWattGross,
    required this.totalUserWatt,
    required this.totalCifAmount,
    required this.countPending,
    required this.countConfirmed,
    required this.countFailed,
  });

  factory MiningSummary.empty() => const MiningSummary(
        totalKwh: 0,
        totalWattGross: 0,
        totalUserWatt: 0,
        totalCifAmount: 0,
        countPending: 0,
        countConfirmed: 0,
        countFailed: 0,
      );

  factory MiningSummary.fromJson(Map<String, dynamic> json) {
    final userWatt = _parseDouble(
      json['total_user_watt'] ?? json['total_watt_earned'],
    );
    return MiningSummary(
      totalKwh: _parseDouble(json['total_kwh']),
      totalWattGross: _parseDouble(
        json['total_watt_gross'] ?? json['total_watt_earned'],
      ),
      totalUserWatt: userWatt,
      totalCifAmount: _parseDouble(json['total_cif_amount']),
      countPending: json['count_pending'] as int? ?? 0,
      countConfirmed: json['count_confirmed'] as int? ?? 0,
      countFailed: json['count_failed'] as int? ?? 0,
    );
  }

  /// Back-compat for economy card headline.
  double get totalWattEarned => totalUserWatt;
}
