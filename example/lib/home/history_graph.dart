import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

class HistoryGraph extends StatelessWidget {
  final BleDevice device;

  const HistoryGraph({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Graph - ${device.name ?? "Unknown Device"}'),
        elevation: 4,
      ),
      body: Center(
        child: Text(
          'This is the history graph for ${device.name ?? "Unknown Device"}.',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
