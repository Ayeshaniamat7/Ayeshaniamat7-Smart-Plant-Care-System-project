import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/plant_service.dart';
import '../../services/sensor_service.dart';
import '../../models/plant_model.dart';
import '../plants/plant_management_screen.dart';

class LiveDashboardScreen extends StatefulWidget {
  const LiveDashboardScreen({Key? key}) : super(key: key);

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

    // Whenever active plant changes, bind sensor stream to plant's hardware deviceId
    final activePlant = plantService.selectedPlant;
    if (activePlant != null) {
      sensorService.listenToDevice(activePlant.deviceId);
    }

    final sensorData = sensorService.currentReadings;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text(
              "FloraCare Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.yard_outlined, color: Colors.white),
            tooltip: "Manage Plants",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: "Sign Out",
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Plant Selector & Hardware Status
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
                        const Text(
                          "No Plants Added",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sensorService.isConnected
                        ? const Color(0xFF4CAF50).withOpacity(0.15)
                        : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sensorService.isConnected ? const Color(0xFF4CAF50) : Colors.redAccent,
                      width: 1,
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

            // Active Plant Hero Card
            if (activePlant != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2E7D32), const Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_florist, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activePlant.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            activePlant.species,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Device ID: ${activePlant.deviceId}",
                            style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            const Text(
              "Real-time Sensor Readings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Metric Cards Grid
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
                  subtitle: activePlant != null
                      ? "Target: ${activePlant.minTemperature}-${activePlant.maxTemperature}°C"
                      : "DHT11 Sensor",
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
                  subtitle: activePlant != null
                      ? "Target: ${activePlant.minSoilMoisture}-${activePlant.maxSoilMoisture}%"
                      : "Analog Moisture",
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }
}
