import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/sensor_history_model.dart';

class SensorHistoryChartScreen extends StatefulWidget {
  const SensorHistoryChartScreen({super.key});

  @override
  State<SensorHistoryChartScreen> createState() => _SensorHistoryChartScreenState();
}

class _SensorHistoryChartScreenState extends State<SensorHistoryChartScreen> {
  // Sample historical timeline data points for demonstration
  final List<SensorHistoryPoint> _sampleHistory = List.generate(12, (index) {
    final time = DateTime.now().subtract(Duration(hours: 12 - index));
    return SensorHistoryPoint(
      timestamp: time,
      soilMoisture: 35.0 + (index * 2.5) % 30,
      temperature: 22.0 + (index * 0.8) % 8,
      humidity: 50.0 + (index * 1.5) % 20,
      lightLevel: 40.0 + (index * 4.0) % 50,
    );
  });

  String _selectedMetric = 'Soil Moisture';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Data History & Visualization"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Telemetry Trends (Past 12 Hours)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Metric Selector Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricSelector("Soil Moisture", const Color(0xFF4CAF50)),
                _buildMetricSelector("Temperature", Colors.orangeAccent),
                _buildMetricSelector("Air Humidity", Colors.lightBlueAccent),
              ],
            ),
            const SizedBox(height: 28),

            // Interactive FLChart Card
            Container(
              height: 300,
              padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < _sampleHistory.length && idx % 3 == 0) {
                            final point = _sampleHistory[idx];
                            return Text(
                              "${point.timestamp.hour}:00",
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpotsForSelectedMetric(),
                      isCurved: true,
                      color: _getMetricColor(),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getMetricColor().withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Average", _getAverageValue()),
                  _buildStatItem("Peak", _getPeakValue()),
                  _buildStatItem("Status", "Stable Trend"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector(String label, Color color) {
    bool isSelected = _selectedMetric == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpotsForSelectedMetric() {
    return List.generate(_sampleHistory.length, (i) {
      final point = _sampleHistory[i];
      double val = 0.0;
      if (_selectedMetric == 'Soil Moisture') val = point.soilMoisture;
      if (_selectedMetric == 'Temperature') val = point.temperature;
      if (_selectedMetric == 'Air Humidity') val = point.humidity;
      return FlSpot(i.toDouble(), val);
    });
  }

  Color _getMetricColor() {
    if (_selectedMetric == 'Soil Moisture') return const Color(0xFF4CAF50);
    if (_selectedMetric == 'Temperature') return Colors.orangeAccent;
    return Colors.lightBlueAccent;
  }

  String _getAverageValue() {
    final spots = _getSpotsForSelectedMetric();
    if (spots.isEmpty) return "0.0";
    double avg = spots.map((e) => e.y).reduce((a, b) => a + b) / spots.length;
    return "${avg.toStringAsFixed(1)}${_selectedMetric == 'Temperature' ? '°C' : '%'}";
  }

  String _getPeakValue() {
    final spots = _getSpotsForSelectedMetric();
    if (spots.isEmpty) return "0.0";
    double max = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return "${max.toStringAsFixed(1)}${_selectedMetric == 'Temperature' ? '°C' : '%'}";
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}