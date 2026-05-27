class MeterWifiConfig {
  final int? id;
  final String ssid;
  final String password;
  final DateTime? updatedAt;

  const MeterWifiConfig({
    this.id,
    required this.ssid,
    required this.password,
    this.updatedAt,
  });

  factory MeterWifiConfig.fromJson(Map<String, dynamic> json) {
    return MeterWifiConfig(
      id: json['id'] as int?,
      ssid: json['ssid'] as String? ?? '',
      password: json['password'] as String? ?? '',
      updatedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
