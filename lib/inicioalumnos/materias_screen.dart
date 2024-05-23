import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  List<Materia> materias = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = await authProvider.cargarToken();
    final numeroControl = await authProvider.cargarNumeroControl();

    if (token != null && numeroControl != null) {
      await cargarMaterias(token, numeroControl);
    } else {
      // Manejar el caso en que token o numeroControl sean nulos
      // Puedes mostrar un mensaje de error o realizar alguna acción específica
      print('Error: token o numeroControl es nulo');
    }
  }

  Future<void> cargarMaterias(String token, String numeroControl) async {
    final response = await http.get(
      Uri.parse('https://proyecto-agiles.onrender.com/materias'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      final filteredMaterias = data
          .where((materia) => materia['NumeroControl'] == numeroControl)
          .toList();
      setState(() {
        materias =
            filteredMaterias.map((json) => Materia.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar materias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
      ),
      body: materias.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: materias.length,
              itemBuilder: (context, index) {
                return MateriaItem(
                  materia: materias[index],
                );
              },
            ),
    );
  }
}

class Materia {
  final String claveMateria;
  final String nombreMateria;
  final int semestre;

  Materia({
    required this.claveMateria,
    required this.nombreMateria,
    required this.semestre,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      claveMateria: json['ClaveMateria'],
      nombreMateria: json['NombreMateria'],
      semestre: json['Semestre'],
    );
  }
}

class MateriaItem extends StatelessWidget {
  final Materia materia;

  MateriaItem({required this.materia});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[200],
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          materia.nombreMateria,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clave: ${materia.claveMateria}'),
            Text('Semestre: ${materia.semestre}'),
          ],
        ),
        onTap: () {
          // Agregar aquí lo que quieras que haga al tocar una materia
        },
      ),
    );
  }
}
