import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'crear_grupo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Materias',
      home: CrearMateria(),
    );
  }
}

class CrearMateria extends StatefulWidget {
  @override
  _CrearMateriaState createState() => _CrearMateriaState();
}

class _CrearMateriaState extends State<CrearMateria> {
  final _claveMateriaController = TextEditingController();
  final _nombreMateriaController = TextEditingController();
  final _semestreController = TextEditingController();

  List<dynamic> materias = [];

  @override
  void initState() {
    super.initState();
    // Iniciar el temporizador para actualizar las materias cada 5 segundos
    Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchMaterias();
    });
  }

  Future<void> _fetchMaterias() async {
    try {
      final response = await http.get(
        Uri.parse('https://proyecto-agiles.onrender.com/materias'),
      );

      if (response.statusCode == 200) {
        setState(() {
          materias = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error al cargar las materias: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las materias: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Materia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _claveMateriaController,
              decoration: InputDecoration(
                labelText: 'Clave de la materia',
              ),
            ),
            TextField(
              controller: _nombreMateriaController,
              decoration: InputDecoration(
                labelText: 'Nombre de la materia',
              ),
            ),
            TextField(
              controller: _semestreController,
              decoration: InputDecoration(
                labelText: 'Semestre',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                _crearMateria(
                  _claveMateriaController.text,
                  _nombreMateriaController.text,
                  int.parse(_semestreController.text),
                );
                _claveMateriaController.clear();
                _nombreMateriaController.clear();
                _semestreController.clear();
              },
              child: Text('Crear materia'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: materias.length,
                itemBuilder: (context, index) {
                  final materia = materias[index];
                  return ListTile(
                    title: Text('${materia['NombreMateria']}'),
                    onTap: () {
                      _mostrarDetallesMateria(context, materia);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearGrupo()),
                );
              },
              child: Text('Ir a crear grupo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearMateria(
      String claveMateria, String nombreMateria, int semestre) async {
    final jsonData = {
      'claveMateria': claveMateria,
      'nombreMateria': nombreMateria,
      'semestre': semestre,
    };

    final body = jsonEncode(jsonData);

    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/materias'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Materia creada correctamente'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la materia: ${response.statusCode}'),
        ),
      );
    }
  }

  void _mostrarDetallesMateria(BuildContext context, dynamic materia) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Materia ${materia['NombreMateria']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clave: ${materia['ClaveMateria']}'),
              Text('Semestre: ${materia['Semestre']}'),
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
}
