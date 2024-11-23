import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'sensor_data_widget.dart';
import 'settings_screen.dart'; // Import the SettingsScreen

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ); // Navigate to SettingsScreen
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ],
        ),
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
