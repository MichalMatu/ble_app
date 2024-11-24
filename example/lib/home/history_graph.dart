import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:typed_data';

class HistoryGraph extends StatefulWidget {
  final BleDevice device;

  const HistoryGraph({super.key, required this.device});

  @override
  HistoryGraphState createState() => HistoryGraphState();
}

class HistoryGraphState extends State<HistoryGraph> {
  String characteristicData = "Loading data...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    readCharacteristicData();
  }

  Future<void> readCharacteristicData() async {
    try {
      final isConnected = await UniversalBle.isPaired(widget.device.deviceId);
      if (isConnected == null || !isConnected) {
        debugPrint("Device not connected. Attempting to connect...");
        await UniversalBle.connect(widget.device.deviceId);
      }

      final Uint8List value = await UniversalBle.readValue(
        widget.device.deviceId,
        "12345678-1234-5678-1234-56789abcdef0", // SERVICE_UUID
        "abcdef02-1234-5678-1234-56789abcdef0", // CHARACTERISTIC_UUID2
      );

      setState(() {
        if (value.isNotEmpty) {
          characteristicData = String.fromCharCodes(value);
        } else {
          characteristicData = "No data received from the characteristic.";
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        characteristicData = "Error reading characteristic: $e";
        isLoading = false;
      });
      debugPrint("Error reading characteristic: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('History Graph - ${widget.device.name ?? "Unknown Device"}'),
        elevation: 4,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  characteristicData,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
