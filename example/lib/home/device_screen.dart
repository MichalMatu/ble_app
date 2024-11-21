import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

class DeviceScreen extends StatelessWidget {
  final BleDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name ?? 'Device'),
        elevation: 4,
      ),
      body: Center(
        // Wrap the Column in a Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Connected to ${device.name ?? "Unknown Device"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic for reading SGP41 sensor data
              },
              child: const Text('Read Sensor Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic for saving data to the microSD card
              },
              child: const Text('Save Data to SD Card'),
            ),
          ],
        ),
      ),
    );
  }
}
