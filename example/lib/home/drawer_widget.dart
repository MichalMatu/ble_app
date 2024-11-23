import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Import the SettingsScreen

class AppDrawer extends StatelessWidget {
  final VoidCallback onBack;

  const AppDrawer({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero, // Adjust padding
            child: SizedBox(
              height: 80, // Reduce header size
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
            onTap: onBack, // Trigger the callback
          ),
        ],
      ),
    );
  }
}
