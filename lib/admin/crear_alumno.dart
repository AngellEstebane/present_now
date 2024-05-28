//2222
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:present_now/admin/filtros.dart';
import 'package:provider/provider.dart';

class CrearAlumno extends StatefulWidget {
  @override
  _CrearAlumnoState createState() => _CrearAlumnoState();
}

class _CrearAlumnoState extends State<CrearAlumno> {
  final TextEditingController numeroControlController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController roleIdController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  bool _isLoading = false;
  String? carreraSeleccionada;

  final List<String> carreras = [
    'Sistemas',
    'Electromecánica',
    'Gestión',
    'Industrial',
    'Renovables',
    'Civil'
  ];

  @override
  void initState() {
    super.initState();
    roleIdController.text = '1';
  }

  void _crearAlumno() async {
    setState(() {
      _isLoading = true;
    });

    String numeroControl = numeroControlController.text.trim();
    String nombre = nombreController.text.trim();
    String carrera = carreraSeleccionada ?? '';
    String contrasena = contrasenaController.text.trim();

    if (numeroControl.isEmpty ||
        nombre.isEmpty ||
        carrera.isEmpty ||
        contrasena.isEmpty ||
        roleIdController.text.isEmpty) {
      _showDialog('Por favor, completa todos los campos.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!NumerControlValidator.isValid(numeroControl)) {
      _showDialog('Número de control inválido');
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

    var alumno = {
      "numeroControl": numeroControl,
      "nombre": nombre,
      "carrera": carrera,
      "roleId": int.tryParse(roleIdController.text) ?? -1,
      "contraseña": contrasena,
    };

    if (alumno['roleId'] == -1) {
      _showDialog('Por favor, ingresa un valor válido para roleId.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/crear/alumno'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alumno),
    );

    if (response.statusCode == 200) {
      _showDialog('Alumno creado exitosamente.');
    } else {
      _showDialog('Error al crear el alumno.');
    }

    setState(() {
      numeroControlController.clear();
      nombreController.clear();
      carreraController.clear();
      contrasenaController.clear();
      carreraSeleccionada = null;
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

  //2222visual
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordVisibilityToggle(),
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Crear Alumno', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue[800],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Alumno',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: numeroControlController,
                decoration: InputDecoration(
                  labelText: 'Número de Control',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: carreraSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                items: carreras.map((String carrera) {
                  return DropdownMenuItem<String>(
                    value: carrera,
                    child: Text(carrera),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    carreraSeleccionada = newValue;
                  });
                },
              ),
              TextField(
                controller: roleIdController,
                decoration: InputDecoration(
                  labelText: 'Role ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 20),
                  ),
                ),
                keyboardType: TextInputType.number,
                enabled: false,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.blue , width: 2),
                      ),
                    ),
                    obscureText: passwordVisibility.obscureText,
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _crearAlumno,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Crear Alumno',
                        style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
