import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearGrupo extends StatefulWidget {
  @override
  _CrearGrupoState createState() => _CrearGrupoState();
}

class _CrearGrupoState extends State<CrearGrupo> {
  final _idMateriaController = TextEditingController();
  final _horaController = TextEditingController();
  final _aulaController = TextEditingController();
  final _rfcDocenteController = TextEditingController();
  final _nombreGrupoController = TextEditingController();
  final _numeroControlController = TextEditingController();

  List<dynamic> grupos = [];

  @override
  void initState() {
    super.initState();
    _fetchGrupos();
  }

  Future<void> _fetchGrupos() async {
    try {
      final response = await http.get(
        Uri.parse('https://proyecto-agiles.onrender.com/grupo'),
      );

      if (response.statusCode == 200) {
        setState(() {
          grupos = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los grupos: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los grupos: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idMateriaController,
              decoration: InputDecoration(labelText: 'ID Materia'),
            ),
            TextField(
              controller: _horaController,
              decoration: InputDecoration(labelText: 'Hora'),
            ),
            TextField(
              controller: _aulaController,
              decoration: InputDecoration(labelText: 'Aula'),
            ),
            TextField(
              controller: _rfcDocenteController,
              decoration: InputDecoration(labelText: 'RFC Docente'),
            ),
            TextField(
              controller: _nombreGrupoController,
              decoration: InputDecoration(labelText: 'Nombre del Grupo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearGrupo,
              child: Text('Crear Grupo'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupo = grupos[index];
                  return ListTile(
                    title: Text('ID Grupo: ${grupo['IdGrupo']}'),
                    subtitle: Text(
                        'ID Materia: ${grupo['Id_Materia']} - Hora: ${grupo['Hora']}'),
                    onTap: () {
                      _mostrarDetallesGrupo(context, grupo);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearGrupo() async {
    final nuevoGrupo = {
      'Id_Materia': _idMateriaController.text,
      'Hora': _horaController.text,
      'Aula': _aulaController.text,
      'RFCDocente': _rfcDocenteController.text,
      'NombreGrupo': _nombreGrupoController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://proyecto-agiles.onrender.com/grupo'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nuevoGrupo),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Grupo creado correctamente'),
          ),
        );
        _limpiarCampos();
        _fetchGrupos();
      } else {
        print(
            'Response body: ${response.body}'); // Agrega esta línea para registrar la respuesta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al crear el grupo: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el grupo: $e'),
        ),
      );
    }
  }

  void _limpiarCampos() {
    _idMateriaController.clear();
    _horaController.clear();
    _aulaController.clear();
    _rfcDocenteController.clear();
    _nombreGrupoController.clear();
  }

  void _mostrarDetallesGrupo(BuildContext context, dynamic grupo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Grupo ${grupo['IdGrupo']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Materia: ${grupo['Id_Materia']}'),
              Text('Hora: ${grupo['Hora']}'),
              Text('Aula: ${grupo['Aula']}'),
              Text('RFC Docente: ${grupo['RFCDocente']}'),
              Text('Nombre del Grupo: ${grupo['NombreGrupo']}'),
              ElevatedButton(
                onPressed: () {
                  _agregarAlumno(grupo['IdGrupo'].toString());
                },
                child: Text('Agregar Alumno'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _agregarAlumno(String idGrupo) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Alumno al Grupo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numeroControlController,
                decoration: InputDecoration(labelText: 'Número de Control'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _agregarAlumnoAGrupo(idGrupo);
                  Navigator.of(context).pop();
                },
                child: Text('Agregar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _agregarAlumnoAGrupo(String idGrupo) async {
    final numeroControl = _numeroControlController.text;

    final nuevoAlumno = {
      'idGrupo': idGrupo,
      'numeroControl': numeroControl,
    };

    final body = jsonEncode(nuevoAlumno);

    try {
      final response = await http.post(
        Uri.parse('https://proyecto-agiles.onrender.com/alumnogrupo'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alumno agregado al grupo correctamente'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al agregar alumno al grupo: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar alumno al grupo: $e'),
        ),
      );
    }
  }
}
