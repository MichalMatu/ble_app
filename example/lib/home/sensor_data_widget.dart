import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:typed_data';
import 'dart:async';

class SensorDataWidget extends StatefulWidget {
  final BleDevice device;

  const SensorDataWidget({super.key, required this.device});

  @override
  SensorDataWidgetState createState() => SensorDataWidgetState();
}

class SensorDataWidgetState extends State<SensorDataWidget> {
  List<Widget> sensorDataWidgets = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  // Start polling for sensor data every 60 seconds
  void startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      readSensorData();
    });

    // Initial read
    readSensorData();
  }

  // Function to discover services and characteristics
  Future<void> discoverServices() async {
    try {
      final services =
          await UniversalBle.discoverServices(widget.device.deviceId);
      for (var service in services) {
        debugPrint("Service: ${service.uuid}");
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
      final isConnected = await UniversalBle.isPaired(widget.device.deviceId);
      if (isConnected == null || !isConnected) {
        debugPrint("Device not connected. Attempting to connect...");
        await UniversalBle.connect(widget.device.deviceId);
      }

      await discoverServices();

      final Uint8List value = await UniversalBle.readValue(
        widget.device.deviceId,
        "12345678-1234-5678-1234-56789abcdef0", // Replace with actual SERVICE_UUID
        "abcdef01-1234-5678-1234-56789abcdef0", // Replace with actual CHARACTERISTIC_UUID
      );

      setState(() {
        if (value.isNotEmpty) {
          final rawData = String.fromCharCodes(value).split(',');
          if (rawData.length >= 3) {
            final temperature = rawData[0];
            final humidity = rawData[1];
            final co2 = rawData[2];

            sensorDataWidgets = [
              _buildSensorRow(
                  Icons.thermostat, "$temperature°C", "Temperature"),
              _buildSensorRow(Icons.water_drop, "$humidity%", "Humidity"),
              _buildSensorRow(Icons.air, "$co2 ppm", "CO2"),
            ];
          } else {
            // Show a loading circle while waiting for complete data
            sensorDataWidgets = [
              const CircularProgressIndicator(),
            ];
          }
        } else {
          sensorDataWidgets = [
            _buildErrorRow("No data received from the sensor."),
          ];
        }
      });
    } catch (e) {
      setState(() {
        sensorDataWidgets = [
          _buildErrorRow("Error reading data: $e"),
        ];
      });
      debugPrint("Error reading data: $e");
    }
  }

  // Helper method to create a row with an icon and text
  Widget _buildSensorRow(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.blue), // Icon
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to create an error row
  Widget _buildErrorRow(String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sensorDataWidgets.isNotEmpty
            ? sensorDataWidgets
            : [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text("Fetching sensor data..."),
              ],
      ),
    );
  }
}
