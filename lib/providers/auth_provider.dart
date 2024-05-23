import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _numeroControl; // Nuevo atributo para almacenar el número de control

  String? get token => _token;
  String? get role => _role;
  String? get numeroControl =>
      _numeroControl; // Nuevo getter para el número de control

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
      _numeroControl = numeroControl; // Almacenar el número de control

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(
          key: 'numero_control',
          value:
              _numeroControl!); // Almacenar el número de control en el almacenamiento seguro

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<String?> cargarNumeroControl() async {
    return await _storage.read(key: 'numero_control');
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

      await _storage.write(key: 'jwt_token', value: _token!);

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<String?> cargarToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> hacerSolicitudProtegida() async {
    final token = await cargarToken();

    print('Enviando solicitud con token: $token');

    final response = await http.get(
      Uri.parse('https://proyecto-agiles.onrender.com/login/maestro'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Respuesta exitosa: ${response.body}');
    } else {
      print('Error en la solicitud: ${response.statusCode}, ${response.body}');
    }
  }


  // Método logout
  Future<void> logout() async {
    // Eliminar el token almacenado de forma segura
    await _storage.delete(key: 'jwt_token');

    // Restablecer las variables de estado
    _token = null;
    _role = null;

    // Notificar a los oyentes para que actualicen la UI
    notifyListeners();
  }
}
