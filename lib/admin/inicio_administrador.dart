import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _crearAlumno() async {
    String numeroControl = numeroControlController.text;
    String nombre = nombreController.text;
    String carrera = carreraController.text;
    String roleId = roleIdController.text;
    String contrasena = contrasenaController.text;

    var alumno = {
      "NumeroControl": numeroControl,
      "Nombre": nombre,
      "Carrera": carrera,
      "RoleID": int.parse(roleId),
      "Contraseña": contrasena,
    };

    var response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/crear/alumnos'),
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
    roleIdController.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Alumno'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Alumno',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: numeroControlController,
              decoration: InputDecoration(labelText: 'Número de Control'),
            ),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: carreraController,
              decoration: InputDecoration(labelText: 'Carrera'),
            ),
            TextField(
              controller: roleIdController,
              decoration: InputDecoration(labelText: 'Role ID'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearAlumno,
              child: Text('Crear Alumno'),
            ),
          ],
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
  final TextEditingController roleIdController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  void _crearMaestro() async {
    String rfc = rfcController.text;
    String nombre = nombreController.text;
    String departamentoId = departamentoIdController.text;
    String roleId = roleIdController.text;
    String contrasena = contrasenaController.text;

    var maestro = {
      "RFC": rfc,
      "Nombre": nombre,
      "DepartamentoID": int.parse(departamentoId),
      "RoleID": int.parse(roleId),
      "Contraseña": contrasena,
    };

    var response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/login/crear/maestros'),
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
    roleIdController.clear();
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
    return Scaffold(
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
            ),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: departamentoIdController,
              decoration: InputDecoration(labelText: 'Departamento ID'),
            ),
            TextField(
              controller: roleIdController,
              decoration: InputDecoration(labelText: 'Role ID'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearMaestro,
              child: Text('Crear Maestro'),
            ),
          ],
        ),
      ),
    );
  }
}
