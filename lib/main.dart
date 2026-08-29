import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bupt_ice/src/rust/api/simple.dart';
import 'package:bupt_ice/src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: BuptIceApp()));
}

class BuptIceApp extends StatelessWidget {
  const BuptIceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUPT ICE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.dark,
        ),
      ),
      home: const SmokeTestPage(),
    );
  }
}

class SmokeTestPage extends StatefulWidget {
  const SmokeTestPage({super.key});

  @override
  State<SmokeTestPage> createState() => _SmokeTestPageState();
}

class _SmokeTestPageState extends State<SmokeTestPage> {
  String _sdkVersion = '';
  List<BuildingDto> _buildings = [];
  int _currentWeek = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBridgeData();
  }

  void _loadBridgeData() {
    try {
      final version = getSdkVersion();
      final buildings = getAllBuildings();
      final week = calculateWeekNumber(
        termStartDate: '2026-02-23',
      );

      setState(() {
        _sdkVersion = version;
        _buildings = buildings;
        _currentWeek = week;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _sdkVersion = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BUPT ICE - FFI Smoke Test'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rust SDK Status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version: $_sdkVersion',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Week Calculation (2026-02-23 -> 2026-08-29): 第 $_currentWeek 周',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Preset Buildings Metadata (${_buildings.length} items)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildings.take(6).map(
                      (b) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text(
                            b.campusId.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(b.name),
                        subtitle: Text(
                          'Key: ${b.key} | Campus: ${b.campusName} | Floors: ${b.defaultFloors.join(", ")}',
                        ),
                      ),
                    ),
                if (_buildings.length > 6)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '... and ${_buildings.length - 6} more buildings loaded O(1) from Rust cache.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
