/// Waitlist user profile fields for the dashboard rewards card.
class UserProfile {
  final int id;
  final String? walletAddress;
  final double pendingWatt;
  /// Net WATT transferred to user wallet (sum of confirmed user_amount).
  final double creditedWatt;
  /// WATT sent to CIF from this user's confirmed mints (~15% legs).
  final double lifetimeCifContributed;
  final String? referralCode;
  final String? referralLink;

  const UserProfile({
    required this.id,
    this.walletAddress,
    required this.pendingWatt,
    required this.creditedWatt,
    this.lifetimeCifContributed = 0,
    this.referralCode,
    this.referralLink,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      walletAddress: json['wallet_address'] as String?,
      pendingWatt: _toDouble(json['pending_watt']),
      creditedWatt: _toDouble(json['credited_watt']),
      lifetimeCifContributed:
          _toDouble(json['lifetime_cif_contributed']),
      referralCode: json['referral_code'] as String?,
      referralLink: json['referral_link'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Today's energy for the dashboard insight card (mint-aligned kWh).
class TodayUsageStats {
  final double todayKwh;

  /// Shown when local today has no DB samples yet (meter may still show live W).
  final String? statusHint;

  const TodayUsageStats({
    required this.todayKwh,
    this.statusHint,
  });
}
