import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'sensor_data_widget.dart';
import 'drawer_widget.dart';

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
      drawer: AppDrawer(
        onBack: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pop(context); // Navigate back to the previous screen
        },
        device: device, // Pass the device to AppDrawer
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SensorDataWidget(device: device),
          ],
        ),
      ),
    );
  }
}
