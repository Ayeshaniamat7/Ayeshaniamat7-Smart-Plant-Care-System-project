import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/plant_model.dart';

class PlantService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PlantModel> _plants = [];
  PlantModel? _selectedPlant;
  bool _isLoading = false;

  List<PlantModel> get plants => _plants;
  PlantModel? get selectedPlant => _selectedPlant;
  bool get isLoading => _isLoading;

  // Stream user's plant profiles from Firestore
  void listenToUserPlants(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _plants = snapshot.docs.map((doc) {
        return PlantModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (_plants.isNotEmpty && (_selectedPlant == null || !_plants.any((p) => p.plantId == _selectedPlant!.plantId))) {
        _selectedPlant = _plants.first;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // Select active plant for dashboard monitoring
  void selectPlant(PlantModel plant) {
    _selectedPlant = plant;
    notifyListeners();
  }

  // Add new plant profile
  Future<bool> addPlant(PlantModel plant) async {
    try {
      DocumentReference docRef = await _firestore.collection('plants').add(plant.toMap());
      // Update with generated ID
      await docRef.update({'plantId': docRef.id});
      return true;
    } catch (e) {
      debugPrint("Error adding plant: $e");
      return false;
    }
  }

  // Update existing plant profile/preferences
  Future<bool> updatePlant(PlantModel plant) async {
    try {
      await _firestore.collection('plants').doc(plant.plantId).update(plant.toMap());
      return true;
    } catch (e) {
      debugPrint("Error updating plant: $e");
      return false;
    }
  }

  // Delete plant profile
  Future<bool> deletePlant(String plantId) async {
    try {
      await _firestore.collection('plants').doc(plantId).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting plant: $e");
      return false;
    }
  }
}
