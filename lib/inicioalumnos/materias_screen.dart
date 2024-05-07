import 'package:flutter/material.dart';
import '../reticulas/ingenieria_industrial.dart';
import '../reticulas/materia_item.dart';
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

  List<Materia> materias = [
    Materia(
      nombre: "Materia 1",
      grupo: "Grupo 1",
      grado: "Grado 1",
      maestro: "Maestro 1",
      horario: "Horario 1",
    ),
    Materia(
      nombre: "Materia 2",
      grupo: "Grupo 2",
      grado: "Grado 2",
      maestro: "Maestro 2",
      horario: "Horario 2",
    ),
    Materia(
      nombre: "Materia 3",
      grupo: "Grupo 3",
      grado: "Grado 3",
      maestro: "Maestro 3",
      horario: "Horario 3",
    ),
    Materia(
      nombre: "Materia 4",
      grupo: "Grupo 4",
      grado: "Grado 4",
      maestro: "Maestro 4",
      horario: "Horario 4",
    ),
    Materia(
      nombre: "Materia 5",
      grupo: "Grupo 5",
      grado: "Grado 5",
      maestro: "Maestro 5",
      horario: "Horario 5",
    ),
    Materia(
      nombre: "Materia 6",
      grupo: "Grupo 6",
      grado: "Grado 6",
      maestro: "Maestro 6",
      horario: "Horario 6",
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Mostrar todas las retículas disponibles al presionar el botón de búsqueda
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
      body: Padding(
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
        title: Text('Reticulas Disponibles'),
      ),
      body: ListView.builder(
        itemCount: reticulas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reticulas[index]),
            onTap: () {
              // Verificar la retícula seleccionada y abrir el archivo correspondiente
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
                  // Acción por defecto si la retícula no coincide con ninguna de las anteriores
                  break;
              }
            },
          );
        },
      ),
    );
  }
}
