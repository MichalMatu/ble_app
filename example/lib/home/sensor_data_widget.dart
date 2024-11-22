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
  String sensorData = "No data available";
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

            sensorData = "Temperature: $temperature°C\n"
                "Humidity: $humidity%\n"
                "CO2: $co2 ppm";
          } else {
            sensorData = "Error: Incomplete sensor data received.";
          }
        } else {
          sensorData = "No data received from the sensor.";
        }
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
    return Center(
      child: Text(
        sensorData,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
