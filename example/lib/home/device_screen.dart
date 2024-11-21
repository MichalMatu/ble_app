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

  // Function to discover services and characteristics
  Future<void> discoverServices() async {
    try {
      final services =
          await UniversalBle.discoverServices(widget.device.deviceId);
      for (var service in services) {
        debugPrint("Service: ${service.characteristics}");
        for (var characteristic in service.characteristics) {
          debugPrint("  Characteristic: ${characteristic.uuid}");
        }
      }
      debugPrint("Service discovery completed.");
    } catch (e) {
      debugPrint("Error discovering services: $e");
    }
  }

  // Function to read sensor data
  Future<void> readSensorData() async {
    try {
      // Ensure the device is connected
      final isConnected = await UniversalBle.isPaired(widget.device.deviceId);
      if (isConnected == null || !isConnected) {
        debugPrint("Device not connected. Attempting to connect...");
        await UniversalBle.connect(widget.device.deviceId);
      }

      // Discover services (if not already done)
      await discoverServices();

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
        title: Text(widget.device.name ?? 'Device'),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Connected to ${widget.device.name ?? "Unknown Device"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
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
