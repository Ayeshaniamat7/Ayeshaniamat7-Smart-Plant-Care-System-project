import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/plant_service.dart';
import '../../services/sensor_service.dart';
import '../../services/ai_service.dart';
import '../../services/pump_control_service.dart';
import '../../models/plant_model.dart';
import '../plants/plant_management_screen.dart';
import '../history/sensor_history_chart_screen.dart';
import '../camera/live_camera_screen.dart';

class LiveDashboardScreen extends StatefulWidget {
  const LiveDashboardScreen({super.key});

  @override
  State<LiveDashboardScreen> createState() => _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends State<LiveDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        final plantService = Provider.of<PlantService>(context, listen: false);
        plantService.listenToUserPlants(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final plantService = Provider.of<PlantService>(context);
    final sensorService = Provider.of<SensorService>(context);
    final aiService = Provider.of<AIService>(context);
    final pumpService = Provider.of<PumpControlService>(context);

    final activePlant = plantService.selectedPlant;
    if (activePlant != null) {
      sensorService.listenToDevice(activePlant.deviceId);
    }

    final sensorData = sensorService.currentReadings;

    // Trigger AI model analysis whenever fresh telemetry arrives
    aiService.analyzeTelemetry(sensorData);
    final aiHealth = aiService.healthDiagnosis;
    final aiWatering = aiService.wateringPrediction;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        titleSpacing: 12,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Color(0xFF4CAF50), size: 22),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                "FloraCare",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Color(0xFF4CAF50)),
            tooltip: "Analytics History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SensorHistoryChartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF4CAF50)),
            tooltip: "Live Camera Stream",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LiveCameraScreen(
                    streamUrl: "http://192.168.153.94:80/stream",
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.yard_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚨 AUTOMATED ALERTS BANNER
            if (aiHealth.alertLevel == "CRITICAL" || aiHealth.alertLevel == "WARNING")
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: aiHealth.alertLevel == "CRITICAL"
                      ? Colors.redAccent.withValues(alpha: 0.2)
                      : Colors.amberAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: aiHealth.alertLevel == "CRITICAL" ? Colors.redAccent : Colors.amberAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      aiHealth.alertLevel == "CRITICAL" ? Icons.error : Icons.warning_amber_rounded,
                      color: aiHealth.alertLevel == "CRITICAL" ? Colors.redAccent : Colors.amberAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI ALERT: ${aiHealth.healthStatus}",
                            style: TextStyle(
                              color: aiHealth.alertLevel == "CRITICAL" ? Colors.redAccent : Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            aiHealth.recommendation,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Top Header: Active Plant & Node Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monitoring Target",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      if (plantService.plants.isNotEmpty)
                        DropdownButton<PlantModel>(
                          value: activePlant,
                          dropdownColor: const Color(0xFF1E293B),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                          items: plantService.plants.map((plant) {
                            return DropdownMenuItem<PlantModel>(
                              value: plant,
                              child: Text(
                                plant.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) plantService.selectPlant(val);
                          },
                        )
                      else
                        const Text("No Plants Added", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sensorService.isConnected
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                        : Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sensorService.isConnected ? const Color(0xFF4CAF50) : Colors.redAccent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sensorService.isConnected ? const Color(0xFF4CAF50) : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sensorService.isConnected ? "LIVE NODE" : "OFFLINE",
                        style: TextStyle(
                          color: sensorService.isConnected ? const Color(0xFF4CAF50) : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 💧 WATER PUMP MANUAL OVERRIDE CONTROL CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop, color: Color(0xFF4CAF50), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Water Pump Override",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pumpService.isPumping ? "🌊 PUMP ACTIVE..." : "Relay Status: READY",
                          style: TextStyle(
                            color: pumpService.isPumping ? Colors.cyanAccent : Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: pumpService.isPumping || activePlant == null
                        ? null
                        : () async {
                            try {
                              await pumpService.triggerWaterPump(
                                deviceId: activePlant.deviceId,
                                durationSeconds: 3,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Pump pulse signal sent to ESP32!"),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Pump error: $e"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Water Now", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🤖 AI RECOMMENDATION & PREDICTION CARD (Overflow-free)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "AI Health & Irrigation Engine",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Diagnosis: ${aiHealth.healthStatus}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Confidence: ${aiHealth.confidence}%",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Predicted Water Vol: ${aiWatering.waterAmountMl} mL", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text("Next Irrigation Window: ~${aiWatering.hoursUntilNextWater} Hours", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Live IoT Telemetry Grid",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 2x2 Sensor Card Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMetricCard(
                  title: "Temperature",
                  value: "${sensorData.temperature.toStringAsFixed(1)} °C",
                  icon: Icons.thermostat,
                  color: Colors.orangeAccent,
                  subtitle: activePlant != null ? "Target: ${activePlant.minTemperature}-${activePlant.maxTemperature}°C" : "DHT11 Sensor",
                ),
                _buildMetricCard(
                  title: "Air Humidity",
                  value: "${sensorData.humidity.toStringAsFixed(0)} %",
                  icon: Icons.water_drop_outlined,
                  color: Colors.lightBlueAccent,
                  subtitle: "DHT11 Sensor",
                ),
                _buildMetricCard(
                  title: "Soil Moisture",
                  value: "${sensorData.soilMoisture} %",
                  icon: Icons.grass,
                  color: const Color(0xFF4CAF50),
                  subtitle: activePlant != null ? "Target: ${activePlant.minSoilMoisture}-${activePlant.maxSoilMoisture}%" : "Analog Moisture",
                ),
                _buildMetricCard(
                  title: "Light Level",
                  value: "${sensorData.lightLevel} %",
                  icon: Icons.wb_sunny_outlined,
                  color: Colors.amberAccent,
                  subtitle: "LDR Sensor",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}