// TODO 3: these tests pass once ServerProfile.fromEnrollmentCode works.
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_vpn/models/server_profile.dart';

import 'helpers.dart';

void main() {
  test('reads every part of an enrollment code', () {
    final profile = ServerProfile.fromEnrollmentCode(code);
    expect(profile.host, '203.0.113.10');
    expect(profile.port, 8443);
    expect(profile.token, 'ACumcmnwvFiuIbeM_nYHg4Oypc8jQ64LHHwOZA920eY');
    expect(profile.fingerprint, fingerprint);
    expect(profile.enrollUrl.toString(), 'https://203.0.113.10:8443/api/enroll');
  });

  test('ignores spaces around a pasted code', () {
    expect(ServerProfile.fromEnrollmentCode('  $code\n').port, 8443);
  });

  test('accepts an IPv6 server in brackets', () {
    final v6 = code.replaceFirst('203.0.113.10', '[2001:db8::1]');
    expect(ServerProfile.fromEnrollmentCode(v6).host, '2001:db8::1');
  });

  test('refuses codes that are not ours, with a friendly message', () {
    for (final bad in [
      '',
      'hello',
      'https://example.com/?host=x',
      code.replaceFirst('port=8443', 'port=99999'),
      code.replaceFirst('&token=ACumcmnwvFiuIbeM_nYHg4Oypc8jQ64LHHwOZA920eY', ''),
      code.replaceFirst(fingerprint, 'abc'),
    ]) {
      expect(() => ServerProfile.fromEnrollmentCode(bad), throwsFormatException, reason: bad);
    }
  });
}
