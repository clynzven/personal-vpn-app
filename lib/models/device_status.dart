/// Live numbers for this device, as the server sees them (from `/api/me`).
class DeviceStatus {
  const DeviceStatus({
    required this.name,
    required this.online,
    required this.lastHandshakeSecsAgo,
    required this.receivedBytes,
    required this.sentBytes,
  });

  final String name;
  final bool online;
  final int? lastHandshakeSecsAgo;
  final int receivedBytes;
  final int sentBytes;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
    name: json['name'] as String? ?? '',
    online: json['online'] as bool? ?? false,
    lastHandshakeSecsAgo: json['last_handshake_secs_ago'] as int?,
    receivedBytes: json['received_bytes'] as int? ?? 0,
    sentBytes: json['sent_bytes'] as int? ?? 0,
  );
}

/// 1536 -> "1.5 KB"
String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return unit == 0 ? '$bytes B' : '${value.toStringAsFixed(1)} ${units[unit]}';
}
