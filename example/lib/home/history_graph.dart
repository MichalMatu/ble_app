import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoryGraph extends StatefulWidget {
  final BleDevice device;

  const HistoryGraph({super.key, required this.device});

  @override
  HistoryGraphState createState() => HistoryGraphState();
}

class HistoryGraphState extends State<HistoryGraph> {
  List<DataPoint> dataPoints = [];
  bool isLoading = true;
  String buffer = ""; // Buffer to store partial data chunks

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

      bool reading = true;
      while (reading) {
        final Uint8List value = await UniversalBle.readValue(
          widget.device.deviceId,
          "12345678-1234-5678-1234-56789abcdef0", // SERVICE_UUID
          "abcdef02-1234-5678-1234-56789abcdef0", // CHARACTERISTIC_UUID2
        );

        if (value.isNotEmpty) {
          final chunk = String.fromCharCodes(value);
          buffer += chunk;

          // Check if the buffer contains complete lines
          final lines = buffer.split('\n');
          for (int i = 0; i < lines.length - 1; i++) {
            addData(lines[i]);
          }

          // Keep the last, possibly incomplete line in the buffer
          buffer = lines.last;

          // Stop if "END_OF_DATA" marker is found
          if (chunk.contains("END_OF_DATA")) {
            reading = false;
          }
        } else {
          reading = false;
          debugPrint("No more data received.");
        }
      }
    } catch (e) {
      debugPrint("Error reading characteristic: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addData(String line) {
    // Data format: "2024/11/26 13:05:44,25.82,45.46,2102"
    if (line.isEmpty) return;

    final parts = line.split(',');
    if (parts.length >= 4) {
      // Extract up to minutes (YYYY/MM/DD HH:MM)
      final timestamp = parts[0].substring(0, 16);
      final temperature = double.tryParse(parts[1]) ?? 0.0;
      final humidity = double.tryParse(parts[2]) ?? 0.0;
      final co2 = double.tryParse(parts[3]) ?? 0.0;

      setState(() {
        dataPoints.add(DataPoint(
          timestamp: timestamp,
          temperature: temperature,
          humidity: humidity,
          co2: co2,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Combined Sensor Data - ${widget.device.name ?? "Unknown Device"}',
          style: const TextStyle(fontSize: 16), // Adjust font size here
        ),
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enablePinching: true,
                  enableMouseWheelZooming: true,
                ),
                primaryXAxis: const CategoryAxis(
                  labelIntersectAction: AxisLabelIntersectAction.hide,
                  labelRotation: 45,
                  labelStyle: TextStyle(fontSize: 12),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: const NumericAxis(
                  name: 'TemperatureAxis',
                  title: AxisTitle(
                    text: 'Temperature (°C)',
                    textStyle: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  opposedPosition: false,
                  axisLine: AxisLine(color: Colors.red),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                axes: const [
                  NumericAxis(
                    name: 'HumidityAxis',
                    title: AxisTitle(
                      text: 'Humidity (%)',
                      textStyle: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                    opposedPosition: true,
                    axisLine: AxisLine(color: Colors.blue),
                    labelStyle: TextStyle(fontSize: 12),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  NumericAxis(
                    name: 'CO2Axis',
                    title: AxisTitle(
                      text: 'CO₂ (ppm)',
                      textStyle: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    opposedPosition: true,
                    axisLine: AxisLine(color: Colors.green),
                    labelStyle: TextStyle(fontSize: 12),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                ],
                series: <CartesianSeries>[
                  LineSeries<DataPoint, String>(
                    name: 'Temperature',
                    dataSource: dataPoints,
                    xValueMapper: (DataPoint dp, _) => dp.timestamp,
                    yValueMapper: (DataPoint dp, _) => dp.temperature,
                    color: Colors.red,
                    width: 2,
                    yAxisName: 'TemperatureAxis',
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<DataPoint, String>(
                    name: 'Humidity',
                    dataSource: dataPoints,
                    xValueMapper: (DataPoint dp, _) => dp.timestamp,
                    yValueMapper: (DataPoint dp, _) => dp.humidity,
                    color: Colors.blue,
                    width: 2,
                    yAxisName: 'HumidityAxis',
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<DataPoint, String>(
                    name: 'CO2',
                    dataSource: dataPoints,
                    xValueMapper: (DataPoint dp, _) => dp.timestamp,
                    yValueMapper: (DataPoint dp, _) => dp.co2,
                    color: Colors.green,
                    width: 2,
                    yAxisName: 'CO2Axis',
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
    );
  }
}

class DataPoint {
  final String timestamp; // Keep as a string for direct use
  final double temperature;
  final double humidity;
  final double co2;

  DataPoint({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.co2,
  });
}
