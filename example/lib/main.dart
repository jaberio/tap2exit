import 'package:flutter/material.dart';
import 'package:tap2exit/tap2exit.dart';

void main() {
  runApp(const MyApp());
}

/// Example app demonstrating the tap2exit plugin.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tap2exit Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

/// Home page with toggles to demonstrate all tap2exit features.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _useToast = false;
  bool _useCustomCallback = false;
  double _durationSeconds = 2.0;
  String _message = 'Press back again to exit';
  ToastDuration _toastDuration = ToastDuration.short;
  ToastGravity _toastGravity = ToastGravity.bottom;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _message);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tap2Exit(
      message: _message,
      duration: Duration(milliseconds: (_durationSeconds * 1000).round()),
      useToast: _useToast,
      toastDuration: _toastDuration,
      toastGravity: _toastGravity,
      onBackFirstPress: _useCustomCallback
          ? (context) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(_message),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
            }
          : null,
      onFirstBackPress: () {
        debugPrint('[tap2exit] First back press detected');
      },
      onExit: () {
        debugPrint('[tap2exit] App is about to exit');
      },
      snackBarStyle: Tap2ExitSnackBarStyle(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        textStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('tap2exit Example'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Header ────────────────────────────────────
            Icon(
              Icons.exit_to_app_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Double-Tap to Exit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Press the system back button to try it out.\n'
              'Customise the behaviour below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // ── Toast toggle ──────────────────────────────
            Card(
              child: SwitchListTile(
                title: const Text('Use native Toast'),
                subtitle:
                    const Text('Android only — falls back to SnackBar on iOS'),
                value: _useToast,
                onChanged: (value) => setState(() => _useToast = value),
              ),
            ),
            const SizedBox(height: 12),

            // ── Toast duration toggle ─────────────────────
            Card(
              child: SwitchListTile(
                title: const Text('Long toast duration'),
                subtitle: Text(
                  _toastDuration == ToastDuration.long
                      ? '≈ 3.5 seconds'
                      : '≈ 2 seconds (default)',
                ),
                value: _toastDuration == ToastDuration.long,
                onChanged: _useToast
                    ? (value) => setState(() => _toastDuration =
                        value ? ToastDuration.long : ToastDuration.short)
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // ── Toast gravity selector ────────────────────
            Card(
              child: ListTile(
                title: const Text('Toast gravity'),
                subtitle: const Text('Where the toast appears on screen'),
                trailing: DropdownButton<ToastGravity>(
                  value: _toastGravity,
                  onChanged: _useToast
                      ? (value) {
                          if (value != null) {
                            setState(() => _toastGravity = value);
                          }
                        }
                      : null,
                  items: ToastGravity.values
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.name),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Custom callback toggle ────────────────────
            Card(
              child: SwitchListTile(
                title: const Text('Custom first-press callback'),
                subtitle: const Text(
                  'Replaces Toast with a custom SnackBar via onBackFirstPress',
                ),
                value: _useCustomCallback,
                onChanged: (value) =>
                    setState(() => _useCustomCallback = value),
              ),
            ),
            const SizedBox(height: 12),

            // ── Duration slider ───────────────────────────
            Card(
              child: ListTile(
                title: const Text('Exit window duration'),
                subtitle: Slider(
                  value: _durationSeconds,
                  min: 1,
                  max: 5,
                  divisions: 8,
                  label: '${_durationSeconds.toStringAsFixed(1)}s',
                  onChanged: (value) =>
                      setState(() => _durationSeconds = value),
                ),
                trailing: Text('${_durationSeconds.toStringAsFixed(1)}s'),
              ),
            ),
            const SizedBox(height: 12),

            // ── Message input ─────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Exit message',
                    border: OutlineInputBorder(),
                  ),
                  controller: _messageController,
                  onChanged: (value) => _message = value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
