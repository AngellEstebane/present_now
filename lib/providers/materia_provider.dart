import 'package:flutter/material.dart';
import 'dart:convert'; // Usar si tu API devuelve datos en JSON
import 'package:http/http.dart' as http;
import 'materia_apod.dart';

class MateriaProvider with ChangeNotifier {
  List<Apod> _materias = [];
  bool _isLoading = false;

  List<Apod> get materias => _materias;
  bool get isLoading => _isLoading;

  MateriaProvider() {
    fetchMaterias();
  }

  Future<void> fetchMaterias() async {
    _isLoading = true;
    notifyListeners();

    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/materias'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      _materias = data.map((item) => Apod.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load materias');
    }

    _isLoading = false;
    notifyListeners();
}
}