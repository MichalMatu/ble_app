import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';

class HistoryGraph extends StatefulWidget {
  final BleDevice device;

  const HistoryGraph({super.key, required this.device});

  @override
  HistoryGraphState createState() => HistoryGraphState();
}

class HistoryGraphState extends State<HistoryGraph> {
  List<FlSpot> temperatureData = [];
  List<FlSpot> humidityData = [];
  List<FlSpot> co2Data = [];
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

      if (value.isNotEmpty) {
        final receivedData = String.fromCharCodes(value);
        parseAndSetData(receivedData);
      } else {
        debugPrint("No data received from the characteristic.");
      }
    } catch (e) {
      debugPrint("Error reading characteristic: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void parseAndSetData(String data) {
    // Assumes data is a CSV-like string: "timestamp,temperature,humidity,co2\n"
    final lines = data.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length >= 4) {
        final timestamp = double.tryParse(parts[0]) ??
            i.toDouble(); // Fallback to index if timestamp fails
        final temperature = double.tryParse(parts[1]) ?? 0.0;
        final humidity = double.tryParse(parts[2]) ?? 0.0;
        final co2 = double.tryParse(parts[3]) ?? 0.0;

        setState(() {
          temperatureData.add(FlSpot(timestamp, temperature));
          humidityData.add(FlSpot(timestamp, humidity));
          co2Data.add(FlSpot(timestamp, co2));
        });
      }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Temperature Data",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                          buildLineChart(temperatureData, Colors.red)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Humidity Data",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child:
                          LineChart(buildLineChart(humidityData, Colors.blue)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "CO2 Data",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: LineChart(buildLineChart(co2Data, Colors.green)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  LineChartData buildLineChart(List<FlSpot> data, Color color) {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          color: color,
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
