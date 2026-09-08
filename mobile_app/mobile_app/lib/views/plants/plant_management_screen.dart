import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/plant_service.dart';
import '../../models/plant_model.dart';

class PlantManagementScreen extends StatelessWidget {
  const PlantManagementScreen({Key? key}) : super(key: key);

  void _showAddPlantDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _speciesController = TextEditingController();
    final _deviceController = TextEditingController(text: "plant_node_01");

    double minMoisture = 30;
    double maxMoisture = 80;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text(
                "Add New Plant Profile",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Plant Nickname (e.g. Living Room Fern)",
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _speciesController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Species (e.g. Monstera Deliciosa)",
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _deviceController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Hardware Node Device ID",
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Target Moisture Range: ${minMoisture.toInt()}% - ${maxMoisture.toInt()}%",
                        style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 13),
                      ),
                      RangeSlider(
                        values: RangeValues(minMoisture, maxMoisture),
                        min: 0,
                        max: 100,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (RangeValues values) {
                          setState(() {
                            minMoisture = values.start;
                            maxMoisture = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  backgroundColor: const Color(0xFF2E7D32),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid ?? '';
                      final newPlant = PlantModel(
                        plantId: '',
                        userId: userId,
                        name: _nameController.text.trim(),
                        species: _speciesController.text.trim(),
                        deviceId: _deviceController.text.trim(),
                        minSoilMoisture: minMoisture.toInt(),
                        maxSoilMoisture: maxMoisture.toInt(),
                        minTemperature: 18.0,
                        maxTemperature: 32.0,
                        minLightLevel: 40,
                        maxLightLevel: 90,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      await Provider.of<PlantService>(context, listen: false).addPlant(newPlant);
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Save Plant", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantService = Provider.of<PlantService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("My Plant Profiles"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () => _showAddPlantDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Plant", style: TextStyle(color: Colors.white)),
      ),
      body: plantService.plants.isEmpty
          ? const Center(
              child: Text(
                "No plants added yet.\nTap 'Add Plant' to register your first profile.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plantService.plants.length,
              itemBuilder: (context, index) {
                final plant = plantService.plants[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile,
                  title: Text(
                    plant.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${plant.species} • Node: ${plant.deviceId}",
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      plantService.deletePlant(plant.plantId);
                    },
                  ),
                );
              },
            ),
    );
  }
}
