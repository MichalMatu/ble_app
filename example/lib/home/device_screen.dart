import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'sensor_data_widget.dart';

class DeviceScreen extends StatelessWidget {
  final BleDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${device.name ?? "Unknown Device"}'),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Use the SensorDataWidget to display sensor data
            SensorDataWidget(device: device),
          ],
        ),
      ),
    );
  }
}
