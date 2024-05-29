import 'package:flutter/material.dart';
import 'package:present_now/admin/crear_alumno.dart';
import 'package:present_now/admin/crear_maestro.dart';
import 'package:present_now/admin/crear_materia.dart';

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
        title: const Text('Inicio Administrador'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearAlumno()),
                  );
                },
                child: const Text('Crear Alumno', style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent, backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearMaestro()),
                  );
                },
                child: const Text('Crear Maestro', style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent, backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearMateria()), // Navegar a la pantalla CrearMateria
                  );
                },
                child: const Text('Crear Materia', style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent, backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
