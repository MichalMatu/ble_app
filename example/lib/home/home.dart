import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:universal_ble_example/data/permission_handler.dart';
import 'device_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bleDevices = <BleDevice>[];
  bool _isScanning = false;
  String? bleAvailability;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    bool permissionsGranted = await _checkAndRequestPermissions();
    if (permissionsGranted) {
      _setupBleCallbacks();
    } else {
      _showPermissionsDialog();
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Check if permissions are already granted
    if (await PermissionHandler.arePermissionsGranted()) {
      return true;
    }

    // Request permissions
    return await PermissionHandler.requiresExplicitAndroidBluetoothPermissions;
  }

  void _setupBleCallbacks() {
    UniversalBle.onScanResult = (result) {
      if (result.name?.isNotEmpty ?? false) {
        int index =
            _bleDevices.indexWhere((e) => e.deviceId == result.deviceId);
        if (index == -1) {
          _bleDevices.add(result);
        } else {
          _bleDevices[index] = result;
        }
        setState(() {});
      }
    };

    UniversalBle.onAvailabilityChange = (state) {
      setState(() {
        bleAvailability = state.name;
      });
    };
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Bluetooth and location permissions are required to scan for BLE devices. Please grant the required permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              bool granted = await _checkAndRequestPermissions();
              if (granted) {
                _setupBleCallbacks();
              } else {
                _showPermissionsDialog();
              }
            },
            child: const Text('Grant Permissions'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> startScan() async {
    await UniversalBle.stopScan();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isScanning = true;
      _bleDevices.clear();
    });
    await UniversalBle.startScan();
  }

  Future<void> stopScan() async {
    await UniversalBle.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan BLE Devices'),
        elevation: 4,
        actions: [
          if (bleAvailability != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('BLE is: '),
                  Text(
                    bleAvailability == 'poweredOn' ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: bleAvailability == 'poweredOn'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isScanning && _bleDevices.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : !_isScanning && _bleDevices.isEmpty
                    ? const Center(child: Text('No devices found.'))
                    : ListView.builder(
                        itemCount: _bleDevices.length,
                        itemBuilder: (context, index) {
                          BleDevice device = _bleDevices[index];
                          return ListTile(
                            title: Text(device.name ?? 'Unknown Device'),
                            subtitle: Text(
                                'Signal strength: ${device.rssi ?? 'Unknown'} dBm'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DeviceScreen(device: device),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isScanning) {
            await stopScan();
          } else {
            await startScan();
          }
        },
        tooltip: _isScanning ? 'Stop Scan' : 'Start Scan',
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MyApp()));
}
