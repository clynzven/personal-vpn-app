// TODO 5: this test passes once the WireGuard config file is built.
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('5: builds a valid WireGuard config', () {
    expect(sampleDevice().toWgQuickConfig(), '''
[Interface]
PrivateKey = $deviceKey
Address = 10.8.0.2/32
DNS = 1.1.1.1, 9.9.9.9

[Peer]
PublicKey = $serverKey
Endpoint = 203.0.113.10:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
''');
  });
}
