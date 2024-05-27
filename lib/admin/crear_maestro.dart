import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:present_now/admin/filtros.dart';
import 'package:provider/provider.dart';

class CrearMaestro extends StatefulWidget {
  @override
  _CrearMaestroState createState() => _CrearMaestroState();
}

class _CrearMaestroState extends State<CrearMaestro> {
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController departamentoIdController =
      TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  bool _isLoading = false;
  String? departamentoSeleccionado;

  final List<String> carreras = [
    '1',
    '2',
    '3',
  ];

  void _crearMaestro() async {
    setState(() {
      _isLoading = true;
    });

    String rfc = rfcController.text.trim();
    String nombre = nombreController.text.trim();
    String departamentoId = departamentoSeleccionado ?? '';
    String contrasena = contrasenaController.text.trim();

    if (rfc.isEmpty ||
        nombre.isEmpty ||
        departamentoId.isEmpty ||
        contrasena.isEmpty) {
      _showDialog('Por favor, completa todos los campos.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!RFCValidator.isValid(rfc)) {
      _showDialog('RFC inválido');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!PasswordValidator.isValid(contrasena)) {
      _showDialog(
          'La contraseña debe tener al menos 8 caracteres, incluir una letra mayúscula, un carácter especial y un número.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var maestro = {
      "rfc": rfc,
      "nombre": nombre,
      "departamentoId": int.parse(departamentoId),
      "roleId": 2,
      "contraseña": contrasena,
    };

    var response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/crear/maestro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(maestro),
    );

    if (response.statusCode == 200) {
      _showDialog('Maestro creado exitosamente.');
    } else {
      _showDialog('Error al crear el maestro.');
    }

    setState(() {
      rfcController.clear();
      nombreController.clear();
      departamentoIdController.clear();
      contrasenaController.clear();
      departamentoSeleccionado = null;
      _isLoading = false;
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resultado"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //2424visual
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordVisibilityToggle(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Maestro'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Maestro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: rfcController,
                decoration: InputDecoration(
                  labelText: 'RFC',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), //Evitar espacios
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9]')), //Sólo letras y números
                  UpperCaseTextInputFormatter(),
                ],
              ),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              DropdownButtonFormField<String>(
                value: departamentoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: carreras.map((String carrera) {
                  return DropdownMenuItem<String>(
                    value: carrera,
                    child: Text(carrera),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    departamentoSeleccionado = newValue;
                  });
                },
              ),
              Consumer<PasswordVisibilityToggle>(
                builder: (context, passwordVisibility, child) {
                  return TextField(
                    controller: contrasenaController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisibility.obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: passwordVisibility.togglePasswordVisibility,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    obscureText: passwordVisibility.obscureText,
                  );
                },
              ),
              TextField(
                controller: TextEditingController(text: '2'),
                decoration: InputDecoration(
                  labelText: 'Role ID',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                enabled: false,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _crearMaestro,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Crear maestro'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
