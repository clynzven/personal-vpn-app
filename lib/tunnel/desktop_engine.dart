import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'tunnel_engine.dart';

/// Runs a program and returns its result. Replaced by a fake in tests.
typedef ProcessRunner = Future<ProcessResult> Function(String executable, List<String> arguments);

/// Desktop engine (macOS, Linux, Windows): uses the official WireGuard tools.
///
/// Creating a network interface needs admin rights, so each connect and disconnect
/// asks the operating system for permission (the Mac shows its password prompt).
/// Arguments are always passed as a list, never glued into a shell command, so a
/// strange file path cannot turn into extra commands.
class DesktopEngine extends TunnelEngine {
  DesktopEngine({ProcessRunner? run, Future<Directory> Function()? configDir})
    : _run = run ?? Process.run,
      _configDir = configDir ?? getApplicationSupportDirectory;

  final ProcessRunner _run;
  final Future<Directory> Function() _configDir;

  /// The tunnel's name. wg-quick takes it from the config file name.
  static const interfaceName = 'pvpn0';

  Future<File> _configFile() async {
    final dir = await _configDir();
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}$interfaceName.conf');
  }

  @override
  Future<void> connect(String wgQuickConfig, {required String endpoint}) async {
    setStatus(TunnelStatus.connecting);
    try {
      final file = await _configFile();
      await file.writeAsString(wgQuickConfig, flush: true);
      if (!Platform.isWindows) {
        // The file holds the private key: only this user may read it.
        await _run('chmod', ['600', file.path]);
      }
      final result = await _run(_executable, _arguments('up', file.path));
      if (result.exitCode != 0) {
        await _deleteQuietly(file);
        setStatus(TunnelStatus.failed, error: _friendly(result));
        return;
      }
      setStatus(TunnelStatus.connected);
    } on ProcessException catch (e) {
      setStatus(TunnelStatus.failed, error: 'Could not start the WireGuard tools: ${e.message}');
    }
  }

  @override
  Future<void> disconnect() async {
    setStatus(TunnelStatus.disconnecting);
    final file = await _configFile();
    try {
      final result = await _run(_executable, _arguments('down', file.path));
      if (result.exitCode != 0 && !_alreadyDown(result)) {
        setStatus(TunnelStatus.failed, error: _friendly(result));
        return;
      }
      await _deleteQuietly(file);
      setStatus(TunnelStatus.disconnected);
    } on ProcessException catch (e) {
      setStatus(TunnelStatus.failed, error: 'Could not stop the tunnel: ${e.message}');
    }
  }

  String get _executable {
    if (Platform.isMacOS) return 'osascript';
    if (Platform.isWindows) return 'powershell';
    return 'pkexec';
  }

  /// The exact command for each operating system. `action` is only ever 'up' or 'down'.
  List<String> _arguments(String action, String path) {
    if (Platform.isMacOS) {
      return macOsArguments(action, path);
    }
    if (Platform.isWindows) {
      final quoted = path.replaceAll("'", "''");
      final args = action == 'up'
          ? "'/installtunnelservice','\"$quoted\"'"
          : "'/uninstalltunnelservice','$interfaceName'";
      return [
        '-NoProfile',
        '-Command',
        "Start-Process -FilePath 'C:\\Program Files\\WireGuard\\wireguard.exe' "
            '-ArgumentList $args -Verb RunAs -Wait',
      ];
    }
    return [
      'env',
      'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      'wg-quick',
      action,
      path,
    ];
  }

  /// macOS: AppleScript shows the system password prompt and runs wg-quick as admin.
  /// The path goes in as an argument and is quoted by AppleScript itself.
  /// PATH must include Homebrew: wg-quick needs Homebrew's newer bash and wireguard-go.
  static List<String> macOsArguments(String action, String path) {
    assert(action == 'up' || action == 'down');
    return [
      '-e',
      'on run argv',
      '-e',
      'do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:\$PATH; '
          'wg-quick " & item 1 of argv & " " & quoted form of (item 2 of argv) '
          'with administrator privileges',
      '-e',
      'end run',
      action,
      path,
    ];
  }

  static bool _alreadyDown(ProcessResult r) =>
      '${r.stderr}'.contains('is not a WireGuard interface') ||
      '${r.stderr}'.contains('does not exist');

  static String _friendly(ProcessResult r) {
    final err = '${r.stderr}'.trim();
    if (err.contains('-128') || err.toLowerCase().contains('canceled')) {
      return 'You cancelled the password prompt, so the tunnel was not changed.';
    }
    if (err.contains('wg-quick: command not found') || err.contains('No such file')) {
      return 'The WireGuard tools are missing. On a Mac run: brew install wireguard-tools wireguard-go';
    }
    if (err.contains('bash') && err.contains('Version')) {
      return 'wg-quick needs a newer bash: brew install bash';
    }
    return err.isEmpty ? 'The tunnel command failed (exit code ${r.exitCode}).' : err;
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Nothing useful to do; the file is private to this user anyway.
    }
  }
}
