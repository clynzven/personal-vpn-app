# Personal VPN: the app (starter)

The starting point for the video **"Your Own VPN: Self-Host a Rust Server and Build the App"**
on ClynzVen Code Academy.

The app already runs. Four key parts are left for you to write, and each has tests that
fail until it's done. When `flutter test` is all green, your VPN app is complete.

## Setup (Mac)

```bash
brew install wireguard-tools wireguard-go cocoapods
flutter pub get
flutter run -d macos
```

You also need your own server running: see
[personal-vpn-server](https://github.com/clynzven/personal-vpn-server) ("Try it on your Mac first").

## Your six TODOs

Search the code for `TODO 1` to `TODO 6`, in this order:

| TODO | File | What you build | Flutter skill |
|---|---|---|---|
| 1 | `lib/screens/home_screen.dart` | Lay out the Home screen | Widgets, the widget tree, `Row`/`Column`/`Expanded` |
| 2 | `lib/screens/home_screen.dart` | Make the big button work | `StatefulWidget`, `setState`, `async`/`await` |
| 3 | `lib/models/server_profile.dart` | Read the enrollment code | Dart classes, factory constructors, null safety, `Uri` |
| 4 | `lib/services/enrollment_service.dart` | Make keys and enroll with the server | `Future`, `async`/`await`, HTTP and JSON, errors |
| 5 | `lib/models/enrolled_device.dart` | Build the WireGuard config file | Strings, lists, string interpolation |
| 6 | `lib/vpn_controller.dart`, `lib/widgets/status_chip.dart` | Connect and disconnect, show the live status | `ChangeNotifier`, streams, `StreamBuilder` |

Check your work after each one:

```bash
flutter test test/todo1_home_screen_test.dart
flutter test test/todo2_server_profile_test.dart
flutter test test/todo3_enrollment_test.dart
flutter test test/todo4_config_test.dart
flutter test test/todo5_connect_test.dart
```

Stuck? Rewatch that part of the video: the code is typed out in full on screen.

## What's already here

Project setup for all platforms, the theme, navigation, the Add server and Settings screens,
key generation, the certificate-pinned HTTPS client, secure key storage, both tunnel engines
(desktop and mobile), and the tests.

## License

MIT
