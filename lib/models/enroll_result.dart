import 'dart:convert';

/// What the server sends back after a successful enrollment.
///
/// These values end up in a WireGuard config file that runs with admin rights,
/// so every field is checked. A hostile server must not be able to sneak in
/// extra lines (for example `PostUp = <any command>`).
class EnrollResult {
  const EnrollResult({
    required this.deviceName,
    required this.address,
    required this.dns,
    required this.serverPublicKey,
    required this.endpoint,
    required this.allowedIps,
    required this.persistentKeepalive,
    required this.statusUrl,
  });

  final String deviceName;
  final String address;
  final List<String> dns;
  final String serverPublicKey;
  final String endpoint;
  final List<String> allowedIps;
  final int persistentKeepalive;
  final Uri statusUrl;

  /// True when all traffic goes through the tunnel (full protection).
  bool get isFullTunnel => allowedIps.contains('0.0.0.0/0') && allowedIps.contains('::/0');

  factory EnrollResult.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('The server sent no valid "$key".');
      }
      if (value.contains('\n') || value.contains('\r')) {
        throw FormatException('The server sent an unsafe "$key".');
      }
      return value;
    }

    List<String> list(String key, bool Function(String) valid) {
      final value = json[key];
      if (value is! List || value.isEmpty) {
        throw FormatException('The server sent no valid "$key".');
      }
      return [
        for (final item in value)
          if (item is String && valid(item))
            item
          else
            throw FormatException('The server sent an unsafe "$key".'),
      ];
    }

    final address = text('address');
    if (!isCidr(address)) throw const FormatException('Bad address from server.');
    final key = text('server_public_key');
    if (!isWireGuardKey(key)) throw const FormatException('Bad server key.');
    final endpoint = text('endpoint');
    if (!isEndpoint(endpoint)) throw const FormatException('Bad endpoint.');
    final keepalive = json['persistent_keepalive'];
    if (keepalive is! int || keepalive < 0 || keepalive > 65535) {
      throw const FormatException('Bad keepalive value.');
    }
    final statusUrl = Uri.tryParse(text('status_url'));
    if (statusUrl == null || statusUrl.scheme != 'http' || statusUrl.host.isEmpty) {
      throw const FormatException('Bad status URL.');
    }

    return EnrollResult(
      deviceName: text('device_name'),
      address: address,
      dns: list('dns', isIp),
      serverPublicKey: key,
      endpoint: endpoint,
      allowedIps: list('allowed_ips', isCidr),
      persistentKeepalive: keepalive,
      statusUrl: statusUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'device_name': deviceName,
    'address': address,
    'dns': dns,
    'server_public_key': serverPublicKey,
    'endpoint': endpoint,
    'allowed_ips': allowedIps,
    'persistent_keepalive': persistentKeepalive,
    'status_url': statusUrl.toString(),
  };
}

/// A 32-byte key in base64, like WireGuard uses.
bool isWireGuardKey(String value) {
  if (value.length != 44) return false;
  try {
    return base64.decode(value).length == 32;
  } on FormatException {
    return false;
  }
}

bool isIp(String value) => _ipv4.hasMatch(value) || _isIpv6(value);

/// An address with a prefix, like 10.8.0.2/32 or ::/0.
bool isCidr(String value) {
  final parts = value.split('/');
  if (parts.length != 2) return false;
  final prefix = int.tryParse(parts[1]);
  if (prefix == null || prefix < 0) return false;
  if (_ipv4.hasMatch(parts[0])) return prefix <= 32;
  if (_isIpv6(parts[0])) return prefix <= 128;
  return false;
}

/// host:port or [ipv6]:port, with a host made of safe characters only.
bool isEndpoint(String value) => _endpoint.hasMatch(value);

final _ipv4 = RegExp(
  r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$',
);
bool _isIpv6(String value) =>
    value.contains(':') &&
    RegExp(r'^[0-9a-fA-F:.]+$').hasMatch(value) &&
    Uri.tryParse('http://[$value]/') != null;
final _endpoint = RegExp(r'^(\[[0-9a-fA-F:.]+\]|[A-Za-z0-9.-]+):([1-9]\d{0,4})$');
