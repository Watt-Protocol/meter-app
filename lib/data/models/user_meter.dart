/// A user meter row from `user_meters` (+ live status from `sensor_readings`).
class UserMeter {
  final int? id;
  final int? userId;
  final String label;
  final String deviceId;
  final String? location;
  final DateTime? lastReadingAt;
  final bool isOnline;

  const UserMeter({
    this.id,
    this.userId,
    required this.label,
    required this.deviceId,
    this.location,
    this.lastReadingAt,
    this.isOnline = false,
  });

  factory UserMeter.fromJson(Map<String, dynamic> json) {
    DateTime? lastAt;
    final raw = json['last_reading_at'];
    if (raw != null) {
      lastAt = DateTime.tryParse(raw.toString());
    }

    return UserMeter(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      label: json['label'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      location: json['location'] as String?,
      lastReadingAt: lastAt,
      isOnline: json['is_online'] == true,
    );
  }

  /// Local-only fallback (no DB id).
  factory UserMeter.local({
    required String label,
    required String deviceId,
    String? location,
  }) {
    return UserMeter(
      label: label,
      deviceId: deviceId,
      location: location,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'label': label,
        'device_id': deviceId,
        if (location != null) 'location': location,
      };

  String get displayLabel => '$label — $deviceId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMeter &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;
}
