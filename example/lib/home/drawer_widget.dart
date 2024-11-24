import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'settings_screen.dart'; // Import the SettingsScreen
import 'history_graph.dart'; // Import the HistoryGraph

class AppDrawer extends StatelessWidget {
  final VoidCallback onBack;
  final BleDevice device;

  const AppDrawer({super.key, required this.onBack, required this.device});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 80,
              child: Container(
                color: Theme.of(context).primaryColor,
                alignment: Alignment.center,
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History Graph'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryGraph(device: device),
                ),
              );
            },
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
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Back'),
            onTap: onBack,
          ),
        ],
      ),
    );
  }
}
