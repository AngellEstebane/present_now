import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:present_now/admin/filtros.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InicioAdministrador(),
    );
  }
}

class InicioAdministrador extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio Administrador'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearAlumno()),
                );
              },
              child: Text('Crear Alumno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearMaestro()),
                );
              },
              child: Text('Crear Maestro'),
            ),
          ],
        ),
      ),
    );
  }
}

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

    numeroControlController.clear();
    nombreController.clear();
    carreraController.clear();
    contrasenaController.clear();
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Resultado"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordVisibilityToggle(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crear Alumno'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Alumno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: numeroControlController,
                decoration: const InputDecoration(labelText: 'Número de Control'),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  UpperCaseTextInputFormatter(),
                ],
              ),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              DropdownButtonFormField<String>(
                value: carreraSeleccionada,
                decoration: const InputDecoration(labelText: 'Carrera'),
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
                decoration: const InputDecoration(labelText: 'Role ID'),
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
                          onPressed:
                              passwordVisibility.togglePasswordVisibility,
                        )),
                    obscureText: passwordVisibility.obscureText,
                  );
                },
              ),
              const SizedBox(height: 20),              
              ElevatedButton(
                onPressed: _crearAlumno,
                child: const Text('Crear Alumno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  void _crearMaestro() async {
    String rfc = rfcController.text.trim();
    String nombre = nombreController.text.trim();
    String departamentoId = departamentoIdController.text.trim();
    String contrasena = contrasenaController.text.trim();

    if (rfc.isEmpty ||
        nombre.isEmpty ||
        departamentoId.isEmpty ||
        contrasena.isEmpty) {
      _showDialog('Por favor, completa todos los campos.');
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

    rfcController.clear();
    nombreController.clear();
    departamentoIdController.clear();
    contrasenaController.clear();
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Resultado"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordVisibilityToggle(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crear Maestro'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear Maestro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: rfcController,
                decoration: InputDecoration(labelText: 'RFC'),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  UpperCaseTextInputFormatter(),
                ],
              ),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: departamentoIdController,
                decoration: InputDecoration(labelText: 'Departamento ID'),
                keyboardType: TextInputType.number,
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
                          onPressed:
                              passwordVisibility.togglePasswordVisibility,
                        )),
                    obscureText: passwordVisibility.obscureText,
                  );
                },
              ),
              TextField(
                controller: TextEditingController(text: '2'),
                decoration: InputDecoration(labelText: 'Role ID'),
                enabled: false,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearMaestro,
                child: Text('Crear Maestro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
