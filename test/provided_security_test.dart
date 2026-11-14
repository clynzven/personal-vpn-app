// Tests for code that comes ready in the starter (they pass from the start).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_vpn/models/enroll_result.dart';
import 'package:personal_vpn/services/key_pair.dart';
import 'package:personal_vpn/services/pinned_client.dart';
import 'package:personal_vpn/tunnel/desktop_engine.dart';
import 'package:personal_vpn/tunnel/tunnel_engine.dart';

import 'helpers.dart';

List<int> hex(String s) => [
  for (var i = 0; i < s.length; i += 2) int.parse(s.substring(i, i + 2), radix: 16),
];

void main() {
  test('key math matches the RFC 7748 test vector (same as wg pubkey)', () async {
    final private = base64.encode(
      hex('77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a'),
    );
    final expected = base64.encode(
      hex('8520f0098930a754748b7ddcb43ef75a0dbf3a0d26381af4eba4a98eaa9b4e6a'),
    );
    expect(await publicKeyFor(private), expected);
  });

  test('a generated key pair belongs together', () async {
    final pair = await generateKeyPair();
    expect(await publicKeyFor(pair.privateKey), pair.publicKey);
  });

  test('certificate fingerprints are SHA-256 in hex', () {
    expect(
      fingerprintOf(utf8.encode('abc')),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  group('server answers are checked before they reach a root-run config file', () {
    test('a normal answer is accepted', () {
      expect(EnrollResult.fromJson(enrollJson()).isFullTunnel, isTrue);
      expect(EnrollResult.fromJson(enrollJson(allowed: ['10.8.0.0/24'])).isFullTunnel, isFalse);
    });

    final attacks = <String, Object>{
      'address': '10.8.0.2/32\nPostUp = rm -rf ~',
      'endpoint': 'evil.example:51820\n[Interface]',
      'server_public_key': 'not-a-key',
      'dns': ['1.1.1.1', 'evil; touch /tmp/x'],
      'allowed_ips': ['0.0.0.0/0', '10.0.0.0/99'],
      'status_url': 'file:///etc/passwd',
      'persistent_keepalive': -1,
    };
    for (final attack in attacks.entries) {
      test('refuses a bad ${attack.key}', () {
        final json = enrollJson()..[attack.key] = attack.value;
        expect(() => EnrollResult.fromJson(json), throwsFormatException);
      });
    }
  });

  test('the status stream is the same object every time (safe for StreamBuilder)', () {
    final engine = FakeEngine();
    expect(identical(engine.status, engine.status), isTrue);
  });

  group('desktop engine', () {
    test('macOS passes the path as an argument, never inside the command text', () {
      const path = "/Users/me/Library/Application Support/x'; rm -rf ~; '/pvpn0.conf";
      final args = DesktopEngine.macOsArguments('up', path);
      expect(args.last, path);
      expect(args.take(args.length - 2).join(' '), isNot(contains('rm -rf')));
      expect(args.join(' '), contains('quoted form of'));
      expect(args.join(' '), contains('/opt/homebrew/bin'));
    });

    test('writes a private config, runs the tool, and removes the file after disconnect', () async {
      final dir = await Directory.systemTemp.createTemp('pvpn');
      final calls = <List<String>>[];
      final engine = DesktopEngine(
        configDir: () async => dir,
        run: (exe, args) async {
          calls.add([exe, ...args]);
          return ProcessResult(0, 0, '', '');
        },
      );
      await engine.connect(
        '[Interface]\nPrivateKey = $deviceKey\n',
        endpoint: '203.0.113.10:51820',
      );
      expect(engine.current, TunnelStatus.connected);
      final conf = File('${dir.path}/pvpn0.conf');
      expect(conf.readAsStringSync(), contains('PrivateKey'));
      expect(calls.first, ['chmod', '600', conf.path]);

      await engine.disconnect();
      expect(engine.current, TunnelStatus.disconnected);
      expect(conf.existsSync(), isFalse, reason: 'the private key file is removed');
      await dir.delete(recursive: true);
    });

    test('a cancelled password prompt becomes a friendly message', () async {
      final dir = await Directory.systemTemp.createTemp('pvpn');
      final engine = DesktopEngine(
        configDir: () async => dir,
        run: (exe, args) async => exe == 'chmod'
            ? ProcessResult(0, 0, '', '')
            : ProcessResult(0, 1, '', 'execution error: User canceled. (-128)'),
      );
      await engine.connect('x', endpoint: 'e:1');
      expect(engine.current, TunnelStatus.failed);
      expect(engine.lastError, contains('cancelled'));
      expect(File('${dir.path}/pvpn0.conf').existsSync(), isFalse);
      await dir.delete(recursive: true);
    });
  });
}
