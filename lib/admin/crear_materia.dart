import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearMateria extends StatefulWidget {
  @override
  _CrearMateriaState createState() => _CrearMateriaState();
}

class _CrearMateriaState extends State<CrearMateria> {
  final TextEditingController _claveMateriaController = TextEditingController();
  final TextEditingController _nombreMateriaController = TextEditingController();
  final TextEditingController _semestreController = TextEditingController();
  final TextEditingController _idGrupoController = TextEditingController();
  final TextEditingController _numeroControlController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();

  List<dynamic> materias = [];
  List<dynamic> historialRegistros = [];
  List<dynamic> grupos = [
    {"IdGrupo": 1, "Id_Materia": "ADMONRED12", "Hora": "00:16:00", "Aula": "LABSIS1", "RfcDocente": "SOGB011002SX3", "NombreGrupo": "B"},
    {"IdGrupo": 2, "Id_Materia": "Agil21", "Hora": "14:00:00", "Aula": "LABSIS3", "RfcDocente": "RFCSALVADOR12", "NombreGrupo": "A"},
    {"IdGrupo": 3, "Id_Materia": "PROLOG", "Hora": "00:04:00", "Aula": "LABSIS1", "RfcDocente": "SOGB011002SX3", "NombreGrupo": "B"},
    {"IdGrupo": 5, "Id_Materia": "123", "Hora": "09:00:00", "Aula": "LABSIS1", "RfcDocente": "ABCB011002SX4", "NombreGrupo": "A"},
    {"IdGrupo": 6, "Id_Materia": "123", "Hora": "16:00:00", "Aula": "LABSIS2", "RfcDocente": "ABCB011002SX4", "NombreGrupo": "B"},
  ];

  @override
  void initState() {
    super.initState();
    fetchMaterias();
    loadMateriasFromPrefs();
    loadHistorialRegistrosFromPrefs();
  }

  Future<void> fetchMaterias() async {
    // Simulando la obtención de materias
    String response = '[{"ClaveMateria":"123","NombreMateria":"POO","Semestre":8},{"ClaveMateria":"ADMONRED12","NombreMateria":"Administracion De Redes","Semestre":8},{"ClaveMateria":"Agil21","NombreMateria":"Metodologias Agiles","Semestre":9},{"ClaveMateria":"ESTDAT2","NombreMateria":"Estructura De Datos","Semestre":3},{"ClaveMateria":"PROLOG","NombreMateria":"Programacion Logica Y Funcional","Semestre":3}]';
    setState(() {
      materias = json.decode(response);
    });
  }

  Future<void> crearMateria() async {
    final nuevaMateria = {
      'ClaveMateria': _claveMateriaController.text,
      'NombreMateria': _nombreMateriaController.text,
      'Semestre': int.parse(_semestreController.text),
    };
    setState(() {
      materias.add(nuevaMateria);
    });

    saveMateriasToPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Materia Creada Exitosamente')),
    );

    _claveMateriaController.clear();
    _nombreMateriaController.clear();
    _semestreController.clear();
  }

  void agregarAlumno() {
    final idGrupo = int.parse(_idGrupoController.text);
    final numeroControl = _numeroControlController.text;
    final nuevoRegistro = {
      'IdGrupo': idGrupo,
      'NumeroControl': numeroControl,
    };
    setState(() {
      historialRegistros.add(nuevoRegistro);
    });

    saveHistorialRegistrosToPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alumno agregado correctamente')),
    );

    _idGrupoController.clear();
    _numeroControlController.clear();
  }

  void eliminarRegistro(int index) {
    setState(() {
      historialRegistros.removeAt(index);
    });

    saveHistorialRegistrosToPrefs();
  }

  Future<void> saveMateriasToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('materias', json.encode(materias));
  }

  Future<void> loadMateriasFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? materiasString = prefs.getString('materias');
    if (materiasString != null) {
      setState(() {
        materias = json.decode(materiasString);
      });
    }
  }

  Future<void> saveHistorialRegistrosToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('historialRegistros', json.encode(historialRegistros));
  }

  Future<void> loadHistorialRegistrosFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historialString = prefs.getString('historialRegistros');
    if (historialString != null) {
      setState(() {
        historialRegistros = json.decode(historialString);
      });
    }
  }

  void buscarPorFiltro() {
    final idGrupo = int.parse(_busquedaController.text);
    final grupo = grupos.firstWhere((g) => g['IdGrupo'] == idGrupo, orElse: () => null);

    if (grupo != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detalles del Grupo $idGrupo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('IdMateria: ${grupo['Id_Materia']}'),
                Text('Hora: ${grupo['Hora']}'),
                Text('Aula: ${grupo['Aula']}'),
                Text('Docente: ${grupo['RfcDocente']}'),
                Text('NombreGrupo: ${grupo['NombreGrupo']}'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró ningún grupo con el IdGrupo $idGrupo')),
      );
    }

    _busquedaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Materia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _claveMateriaController,
              decoration: InputDecoration(labelText: 'Clave Materia'),
            ),
            TextField(
              controller: _nombreMateriaController,
              decoration: InputDecoration(labelText: 'Nombre Materia'),
            ),
            TextField(
              controller: _semestreController,
              decoration: InputDecoration(labelText: 'Semestre'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: crearMateria,
              child: Text('Crear Materia'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(labelText: 'Buscar por IdGrupo'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: buscarPorFiltro,
              child: Text('Busqueda Por Filtro'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: materias.length,
                itemBuilder: (context, index) {
                  final materia = materias[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(materia['NombreMateria']),
                              subtitle: Text('Clave: ${materia['ClaveMateria']} - Semestre: ${materia['Semestre']}'),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Agregar Alumno a ${materia['NombreMateria']}'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _idGrupoController,
                                          decoration: InputDecoration(labelText: 'ID Grupo'),
                                          keyboardType: TextInputType.number,
                                        ),
                                        TextField(
                                          controller: _numeroControlController,
                                          decoration: InputDecoration(labelText: 'Número de Control'),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          agregarAlumno();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Agregar Alumno'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Agregar Alumno'),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text('Mostrar Grupos'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Grupos de ${materia['NombreMateria']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: grupos
                                      .where((g) => g['Id_Materia'] == materia['ClaveMateria'])
                                      .map((grupo) => ListTile(
                                            title: Text('Grupo ${grupo['NombreGrupo']}'),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Hora: ${grupo['Hora']}'),
                                                Text('Aula: ${grupo['Aula']}'),
                                                Text('Docente: ${grupo['RfcDocente']}'),
                                              ],
                                            ),
                                          ))
                                      .toList(),
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
                        },
                      ),
                      ListTile(
                        title: Text('Historial Alumnos Agregados '),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Historial de registros de ${materia['NombreMateria']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 0; i < historialRegistros.length; i++)
                                      ListTile(
                                        title: Text('ID Grupo: ${historialRegistros[i]['IdGrupo']}, Número de Control: ${historialRegistros[i]['NumeroControl']}'),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            eliminarRegistro(i);
                                            Navigator.of(context).pop();
                                          },
                                        ),
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
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CrearMateria(),
  ));
}





