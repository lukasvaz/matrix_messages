import 'package:flutter/material.dart';
import 'package:frontend/services/database_hospitals/database_helper.dart';

class HospitalesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _hospitales = [];

  List<Map<String, dynamic>> get hospitales => _hospitales;

  // Función para cargar hospitales desde la base de datos
  Future<void> cargarHospitales() async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> hospitales = await dbHelper.getAllHospitals();
    _hospitales = hospitales;
    notifyListeners();  // Notifica a los widgets para que se actualicen
  }
}
