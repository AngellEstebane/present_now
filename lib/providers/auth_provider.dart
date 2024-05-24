import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _numeroControl; // Nuevo atributo para almacenar el número de control
  String? _nombreAlumno; // Atributo para almacenar el nombre del alumno
  String? _nombreProfesor; // Atributo para almacenar el nombre del profesor
  String? _rfc; // Atributo para almacenar el rfc del profesor

  String? get token => _token;
  String? get role => _role;
  String? get numeroControl =>
      _numeroControl; // Nuevo getter para el número de control
  String? get nombreAlumno => _nombreAlumno; // get para el nombre del alumno
  String? get nombreProfesor =>
      _nombreProfesor; // get para el nombre del profesor
  String? get rfc => _rfc; // get para el rfc del profesor

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
      _nombreAlumno = await getNombreAlumno(numeroControl);

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
      _rfc = rfc;

      _nombreProfesor = await getNombreProfesor(rfc);

      await _storage.write(key: 'jwt_token', value: _token!);

      await _storage.write(key: 'rfc', value: _rfc!);

      notifyListeners();
    } else {
      throw Exception('Autenticación fallida');
    }
  }

  Future<String?> getNombreProfesor(String rfc) async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/profesores/$rfc'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Nombre'];
    } else {
      throw Exception('Error al obtener el nombre del alumno');
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
    _nombreAlumno = null;
    _numeroControl = null;
    _rfc = null;
    _nombreProfesor = null;

    // Notificar a los oyentes para que actualicen la UI
    notifyListeners();
  }
}
