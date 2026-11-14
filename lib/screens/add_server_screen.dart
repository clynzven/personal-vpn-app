import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../vpn_controller.dart';

/// Paste a one-time enrollment code to add this device to your server.
class AddServerScreen extends StatefulWidget {
  const AddServerScreen({super.key, required this.controller});
  final VpnController controller;

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _code.text = data!.text!.trim();
  }

  Future<void> _submit() async {
    final ok = await widget.controller.addServer(_code.text);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final busy = widget.controller.busy;
        return Scaffold(
          appBar: AppBar(title: const Text('Add server')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Brand.orange, Color(0xFFF2994A)]),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect this device',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text('Paste the one-time code from your dashboard (pvpn://enroll…)'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 12),
              TextField(
                key: const Key('code-field'),
                controller: _code,
                minLines: 3,
                maxLines: 5,
                enabled: !busy,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Brand.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  hintText: 'pvpn://enroll?host=…',
                  suffixIcon: IconButton(
                    tooltip: 'Paste',
                    icon: const Icon(Icons.content_paste),
                    onPressed: busy ? null : _paste,
                  ),
                ),
              ),
              if (widget.controller.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.controller.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('submit-code'),
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add this device'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.key_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your device makes its own key. Only the public half is sent to your server.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
