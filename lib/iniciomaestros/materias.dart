import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Alumno {
  final String nombre;
  final String noDeControl;

  Alumno({
    required this.nombre,
    required this.noDeControl,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'noDeControl': noDeControl,
    };
  }

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      nombre: json['nombre'],
      noDeControl: json['noDeControl'],
    );
  }
}

class Materia {
  final String nombre;
  final String grupo;
  final String grado;
  final String maestro;
  final String horario;
  List<Alumno> alumnos;

  Materia({
    required this.nombre,
    required this.grupo,
    required this.grado,
    required this.maestro,
    required this.horario,
    List<Alumno>? alumnos,
  }) : this.alumnos = alumnos ?? [];

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'grupo': grupo,
      'grado': grado,
      'maestro': maestro,
      'horario': horario,
      'alumnos': alumnos.map((alumno) => alumno.toJson()).toList(),
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      nombre: json['nombre'],
      grupo: json['grupo'],
      grado: json['grado'],
      maestro: json['maestro'],
      horario: json['horario'],
      alumnos: (json['alumnos'] as List).map((item) => Alumno.fromJson(item)).toList(),
    );
  }
}

class MateriaItem extends StatelessWidget {
  final Materia materia;
  final VoidCallback? onDelete;
  final VoidCallback? onAddAlumno;

  const MateriaItem({
    required this.materia,
    this.onDelete,
    this.onAddAlumno,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.withOpacity(0.2),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materia.nombre,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Text('Grupo: ${materia.grupo}'),
          Text('Grado: ${materia.grado}'),
          Text('Maestro: ${materia.maestro}'),
          Text('Horario: ${materia.horario}'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: onAddAlumno,
            child: Text('Agregar Alumno'),
          ),
          SizedBox(height: 8),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class MaestroMateriaItem extends StatelessWidget {
  final Materia materia;
  final VoidCallback? onDelete;
  final VoidCallback? onAddAlumno;

  const MaestroMateriaItem({
    required this.materia,
    this.onDelete,
    this.onAddAlumno,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MateriaAlumnosScreen(materia: materia)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre: ${materia.nombre}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Grupo: ${materia.grupo}'),
              Text('Grado: ${materia.grado}'),
              Text('Maestro: ${materia.maestro}'),
              Text('Horario: ${materia.horario}'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: onAddAlumno,
                child: Text('Agregar Alumno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MateriaAlumnosScreen extends StatelessWidget {
  final Materia materia;

  const MateriaAlumnosScreen({required this.materia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${materia.nombre} - Alumnos'),
      ),
      body: ListView.builder(
        itemCount: materia.alumnos.length,
        itemBuilder: (context, index) {
          final alumno = materia.alumnos[index];
          return ListTile(
            title: Text(alumno.nombre),
            subtitle: Text('No de Control: ${alumno.noDeControl}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarAlumno(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Función para agregar un nuevo alumno
  void _agregarAlumno(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String materiaKey = 'materia_${materia.nombre}_${materia.grupo}_${materia.horario}';
    final String alumnoKey = 'alumnos_$materiaKey';

    // Mostrar diálogo para ingresar datos del alumno
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nombre = '';
        String noDeControl = '';
        return AlertDialog(
          title: Text('Agregar Alumno'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  nombre = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'No de Control'),
                onChanged: (value) {
                  noDeControl = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (nombre.isNotEmpty && noDeControl.isNotEmpty) {
                  final Alumno nuevoAlumno = Alumno(nombre: nombre, noDeControl: noDeControl);
                  final List<String> alumnos = prefs.getStringList(alumnoKey) ?? [];
                  alumnos.add(jsonEncode(nuevoAlumno.toJson()));
                  prefs.setStringList(alumnoKey, alumnos);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
