import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:typed_data';

class DeviceScreen extends StatefulWidget {
  final BleDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  String sensorData = "No data available";

  // Function to read sensor data
  Future<void> readSensorData() async {
    try {
      // Ensure the device is connected
      final isConnected = await UniversalBle.isPaired(widget.device.deviceId);
      if (isConnected == null || !isConnected) {
        debugPrint("Device not connected. Attempting to connect...");
        await UniversalBle.connect(widget.device.deviceId);
      }

      // Read value from the characteristic
      final Uint8List value = await UniversalBle.readValue(
        widget.device.deviceId,
        "12345678-1234-5678-1234-56789abcdef0", // Replace with actual SERVICE_UUID
        "abcdef01-1234-5678-1234-56789abcdef0", // Replace with actual CHARACTERISTIC_UUID
      );

      setState(() {
        sensorData = value.isNotEmpty
            ? String.fromCharCodes(value) // Convert data to a readable string
            : "No data received from the sensor";
      });
    } catch (e) {
      setState(() {
        sensorData = "Error reading data: $e";
      });
      debugPrint("Error reading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name ?? "Unknown Device"}'),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: readSensorData,
              child: const Text('Read Sensor Data'),
            ),
            const SizedBox(height: 20),
            Text(
              sensorData,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
