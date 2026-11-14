import 'package:personal_vpn/models/enroll_result.dart';
import 'package:personal_vpn/models/enrolled_device.dart';
import 'package:personal_vpn/tunnel/tunnel_engine.dart';

const fingerprint = '0ac5a40e48dfb4834fc5743c9b427779239b35cbd3ecf4c96c17f58de0f6e56e';
const serverKey = '3h94E31iFN60u/pPoKXpjOtNyUqFfM+HKhQEG/P6Ty4=';
const deviceKey = 'yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=';

const code =
    'pvpn://enroll?host=203.0.113.10&port=8443&token=ACumcmnwvFiuIbeM_nYHg4Oypc8jQ64LHHwOZA920eY&fp=$fingerprint';

Map<String, dynamic> enrollJson({List<String> allowed = const ['0.0.0.0/0', '::/0']}) => {
  'device_name': 'MacBook Air',
  'address': '10.8.0.2/32',
  'dns': ['1.1.1.1', '9.9.9.9'],
  'server_public_key': serverKey,
  'endpoint': '203.0.113.10:51820',
  'allowed_ips': allowed,
  'persistent_keepalive': 25,
  'status_url': 'http://10.8.0.1:8080/api/me',
};

EnrolledDevice sampleDevice({List<String> allowed = const ['0.0.0.0/0', '::/0']}) => EnrolledDevice(
  serverHost: '203.0.113.10',
  serverPort: 8443,
  fingerprint: fingerprint,
  privateKey: deviceKey,
  result: EnrollResult.fromJson(enrollJson(allowed: allowed)),
);

/// A tunnel engine that records what it was asked to do.
class FakeEngine extends TunnelEngine {
  final configs = <String>[];
  bool failNext = false;

  @override
  Future<void> connect(String wgQuickConfig, {required String endpoint}) async {
    configs.add(wgQuickConfig);
    setStatus(TunnelStatus.connecting);
    if (failNext) {
      failNext = false;
      setStatus(
        TunnelStatus.failed,
        error: 'You cancelled the password prompt, so the tunnel was not changed.',
      );
      return;
    }
    setStatus(TunnelStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    setStatus(TunnelStatus.disconnecting);
    setStatus(TunnelStatus.disconnected);
  }
}
