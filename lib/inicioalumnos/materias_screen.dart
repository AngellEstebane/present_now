import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../reticulas/ingenieria_industrial.dart';
import '../reticulas/ingenieria_electromecanica.dart';
import '../reticulas/ingenieria_energias_renovables.dart';
import '../reticulas/ingenieria_gestion.dart';
import '../reticulas/ingenieria_sistemas.dart';

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  List<String> reticulas = [
    "Ingeniería Industrial",
    "Ingeniería Electromecánica",
    "Ingeniería en Sistemas Computacionales",
    "Ingeniería en Gestión Empresarial",
    "Ingeniería en Energías Renovables",
  ];

  List<Materia> materias = [];

  @override
  void initState() {
    super.initState();
    cargarMaterias();
  }

  // Carga las materias desde la API
  Future<void> cargarMaterias() async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/materias'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        materias = data.map((json) => Materia.fromJson(json)).toList();
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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReticulasScreen(reticulas: reticulas),
                ),
              );
            },
          ),
        ],
      ),
      body: materias.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: materias.length,
                itemBuilder: (BuildContext context, int index) {
                  return MateriaItem(
                    materia: materias[index],
                  );
                },
              ),
            ),
    );
  }
}

class ReticulasScreen extends StatelessWidget {
  final List<String> reticulas;

  ReticulasScreen({required this.reticulas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retículas Disponibles'),
      ),
      body: ListView.builder(
        itemCount: reticulas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reticulas[index]),
            onTap: () {
              switch (reticulas[index]) {
                case "Ingeniería Industrial":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngenieriaIndustrialScreen(),
                    ),
                  );
                  break;
                case "Ingeniería Electromecánica":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngenieriaElectromecanicaScreen(),
                    ),
                  );
                  break;
                case "Ingeniería en Sistemas Computacionales":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngenieriaSistemasScreen(),
                    ),
                  );
                  break;
                case "Ingeniería en Gestión Empresarial":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngenieriaGestionScreen(),
                    ),
                  );
                  break;
                case "Ingeniería en Energías Renovables":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          IngenieriaEnergiasRenovablesScreen(),
                    ),
                  );
                  break;
                default:
                  break;
              }
            },
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
  final int planEstudioId;
  final String horaInicio;
  final String profesorRfc;
  final String numeroControl;
  final String aula;

  Materia({
    required this.claveMateria,
    required this.nombreMateria,
    required this.semestre,
    required this.planEstudioId,
    required this.horaInicio,
    required this.profesorRfc,
    required this.numeroControl,
    required this.aula,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      claveMateria: json['ClaveMateria'],
      nombreMateria: json['NombreMateria'],
      semestre: json['Semestre'],
      planEstudioId: json['PlanEstudioId'],
      horaInicio: json['HoraInicio'],
      profesorRfc: json['ProfesorRFC'],
      numeroControl: json['NumeroControl'],
      aula: json['aula'],
    );
  }
}

class MateriaItem extends StatelessWidget {
  final Materia materia;

  MateriaItem({required this.materia});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(materia.nombreMateria, style: TextStyle(fontSize: 16)),
            Text('Grupo: ${materia.numeroControl}'),
            Text('Grado: ${materia.semestre}'),
            Text('Maestro: ${materia.profesorRfc}'),
            Text('Horario: ${materia.horaInicio}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Aula: ${materia.aula}'),
          ],
        ),
      ),
    );
  }
}
