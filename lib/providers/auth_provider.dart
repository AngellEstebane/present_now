import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _numeroControl;
  String? _nombreAlumno;
  String? _nombreProfesor;
  String? _rfc;
  String? _credencial;
  List<Map<String, String>> _materias = [];

  String? get token => _token;
  String? get role => _role;
  String? get numeroControl => _numeroControl;
  String? get nombreAlumno => _nombreAlumno;
  String? get nombreProfesor => _nombreProfesor;
  String? get rfc => _rfc;
  String? get credencial =>
      _credencial; // Getter para la credencial del administrador
  List<Map<String, String>> get materias => _materias;

  final _storage = FlutterSecureStorage();

  Future<void> autenticarAlumno(String numeroControl, String password) async {
    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/alumno'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numeroControl': numeroControl,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _role = 'alumno';
      _numeroControl = numeroControl;
      _nombreAlumno = await getNombreAlumno(numeroControl);

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(key: 'numero_control', value: _numeroControl!);

      await cargarMateriasAlumno();

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<String?> getNombreAlumno(String numeroControl) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/alumnos/$numeroControl'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Nombre'];
    } else {
      throw Exception('Error al obtener el nombre del alumno');
    }
  }

  Future<void> autenticarMaestro(String rfc, String password) async {
    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/maestro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'rfc': rfc,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _role = 'maestro';
      _rfc = rfc;

      _nombreProfesor = await getNombreProfesor(rfc);

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(key: 'rfc', value: _rfc!);

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<List<Map<String, String>>> getMateriasProfesor(String rfc) async {
    final response = await http.get(
      Uri.parse(
          'https://proyecto-agiles.onrender.com/profesor/materias/aulas?rfc=$rfc'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((materia) => {
                'NombreMateria': materia['NombreMateria'].toString(),
                'NombreGrupo': materia['NombreGrupo'].toString(),
                'Hora': materia['Hora'].toString(),
                'AulaNombre': materia['AulaNombre'].toString(),
              })
          .toList();
    } else {
      throw Exception('Error al obtener las materias del profesor');
    }
  }

  Future<String?> getNombreProfesor(String rfc) async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/profesores/$rfc'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Nombre'];
    } else {
      throw Exception('Error al obtener el nombre del profesor');
    }
  }

  Future<void> autenticarAdministrador(
      String credencial, String password) async {
    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Credencial': credencial,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _role = 'administrador';
      _credencial = credencial;

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(key: 'credencial', value: _credencial!);

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<String?> cargarToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> cargarMateriasAlumno() async {
    if (_numeroControl == null) return;

    final response = await http.get(
      Uri.parse(
          'https://proyecto-agiles.onrender.com/materias/alumno?numero_control=$_numeroControl'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _materias = data
          .map((materia) => {
                'ClaveMateria': materia['ClaveMateria'].toString(),
                'NombreMateria': materia['NombreMateria'].toString(),
                'Hora': materia['Hora'].toString(),
              })
          .toList();
    } else {
      throw Exception('Error al obtener las materias del alumno');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');

    _token = null;
    _role = null;
    _nombreAlumno = null;
    _numeroControl = null;
    _rfc = null;
    _nombreProfesor = null;
    _credencial = null;
    _materias = [];

    notifyListeners();
  }
}
