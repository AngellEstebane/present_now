import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  // Solicitudes HTTP
  final String _baseUrl = 'https://proyecto-agiles.onrender.com';
  final storage = FlutterSecureStorage();

  //login alumnos

  Future<String?> login_alumnos(String numeroControl, String password) async {
    final authData = {'numeroControl': numeroControl, 'password': password};

    final url = Uri.parse('$_baseUrl/login/alumno');

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(authData),
      );

      print('Respuesta del servidor: ${resp.body}');

      if (resp.statusCode == 200) {
        final Map<String, dynamic> decodedResp = json.decode(resp.body);

        if (decodedResp.containsKey('token')) {
          await storage.write(key: 'token', value: decodedResp['token']);
          return null;
        } else {
          return 'La respuesta del servidor no contiene un token';
        }
      } else {
        return 'Error en la solicitud: ${resp.reasonPhrase}';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud';
    }
  }

  Future<String?> login_maestros(String rfc, String password) async {
    final authData = {'rfc': rfc, 'password': password};

    final url = Uri.parse('$_baseUrl/login/alumnos');

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(authData),
      );

      print('Respuesta del servidor: ${resp.body}');

      if (resp.statusCode == 200) {
        final Map<String, dynamic> decodedResp = json.decode(resp.body);

        if (decodedResp.containsKey('token')) {
          await storage.write(key: 'token', value: decodedResp['token']);
          return null;
        } else {
          return 'La respuesta del servidor no contiene un token';
        }
      } else {
        return 'Error en la solicitud: ${resp.reasonPhrase}';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud';
    }
  }

  Future logout() async {
    await storage.delete(key: 'token');
    return;
  }

  Future<String> readToken() async {
    return await storage.read(key: 'token') ?? '';
  }
}
