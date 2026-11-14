import 'dart:async';

import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

import 'tunnel_engine.dart';

/// Mobile engine (iPhone, iPad, Android): the system VPN APIs through the
/// wireguard_flutter_plus plugin. iOS needs a Packet Tunnel extension in Xcode
/// and a paid Apple Developer account; Android uses VpnService. See README.md.
class MobileEngine extends TunnelEngine {
  MobileEngine({this.providerBundleIdentifier = 'dev.clynzven.personalVpn.WGExtension'});

  final String providerBundleIdentifier;
  final _wireguard = WireGuardFlutter.instance;
  StreamSubscription<VpnStage>? _stages;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _wireguard.initialize(interfaceName: 'pvpn0', vpnName: 'Personal VPN');
    _stages = _wireguard.vpnStageSnapshot.listen((stage) => setStatus(_map(stage)));
    _initialized = true;
  }

  @override
  Future<void> connect(String wgQuickConfig, {required String endpoint}) async {
    setStatus(TunnelStatus.connecting);
    try {
      await _init();
      await _wireguard.startVpn(
        serverAddress: endpoint,
        wgQuickConfig: wgQuickConfig,
        providerBundleIdentifier: providerBundleIdentifier,
      );
    } on Object catch (e) {
      setStatus(TunnelStatus.failed, error: 'Could not start the VPN: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    setStatus(TunnelStatus.disconnecting);
    try {
      await _wireguard.stopVpn();
    } on Object catch (e) {
      setStatus(TunnelStatus.failed, error: 'Could not stop the VPN: $e');
    }
  }

  static TunnelStatus _map(VpnStage stage) => switch (stage) {
    VpnStage.connected => TunnelStatus.connected,
    VpnStage.disconnected || VpnStage.noConnection => TunnelStatus.disconnected,
    VpnStage.disconnecting || VpnStage.exiting => TunnelStatus.disconnecting,
    VpnStage.denied => TunnelStatus.failed,
    _ => TunnelStatus.connecting,
  };

  @override
  Future<void> dispose() async {
    await _stages?.cancel();
    await super.dispose();
  }
}
