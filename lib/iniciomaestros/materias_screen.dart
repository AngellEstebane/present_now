import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  List<Materia> materiasAgregadas = [];
  List<String> listaNumeroControl = [];
  List<String> listaRFCMaestro = [];
  List<int> listaPlanEstudioId = [];

  @override
  void initState() {
    super.initState();
    cargarMaterias();
    cargarOpciones();
  }

  Future<void> cargarMaterias() async {
    final response =
        await http.get(Uri.parse('https://proyecto-agiles.onrender.com/materias'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        materiasAgregadas =
            data.map((json) => Materia.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar materias');
    }
  }

  Future<void> cargarOpciones() async {
    final responseAlumnos =
        await http.get(Uri.parse('https://proyecto-agiles.onrender.com/alumnos'));
    final responseProfesores =
        await http.get(Uri.parse('https://proyecto-agiles.onrender.com/profesores'));
    final responsePlanesEstudio =
        await http.get(Uri.parse('https://proyecto-agiles.onrender.com/planesestudio'));

    if (responseAlumnos.statusCode == 200 &&
        responseProfesores.statusCode == 200 &&
        responsePlanesEstudio.statusCode == 200) {
      final dataAlumnos = jsonDecode(responseAlumnos.body);
      final dataProfesores = jsonDecode(responseProfesores.body);
      final dataPlanesEstudio = jsonDecode(responsePlanesEstudio.body);

      setState(() {
        listaNumeroControl = List<String>.from(dataAlumnos.map((alumno) => alumno['numero_control']));
        listaRFCMaestro = List<String>.from(dataProfesores.map((profesor) => profesor['rfc']));
        listaPlanEstudioId = List<int>.from(dataPlanesEstudio.map((plan) => plan['id']));
      });
    } else {
      throw Exception('Error al cargar las opciones');
    }
  }

  // Agrega una nueva materia y la envía a la API
  Future<void> agregarMateria(Materia materia) async {
    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/materias'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(materia.toJson()),
    );

    if (response.statusCode == 201) {
      setState(() {
        materiasAgregadas.add(materia);
      });
    } else {
      // Manejo de errores
      throw Exception('Error al agregar materia');
    }
  }

  // Elimina una materia de la lista
  void eliminarMateria(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta materia?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                setState(() {
                  materiasAgregadas.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Edita una materia
  void editarMateria(Materia materia, int index) async {
    String nuevoClaveMateria = materia.ClaveMateria ?? '';
    String nuevoNombre = materia.NombreMateria ?? '';
    int nuevoSemestre = materia.Semestre ?? 0;
    int nuevoPlanEstudioId = materia.PlanEstudioId ?? 0;
    String nuevoHoraInicio = materia.HoraInicio ?? '';
    String nuevoProfesorRFC = materia.ProfesorRFC ?? '';
    String nuevoNumeroControl = materia.NumeroControl ?? '';
    String nuevoAula = materia.aula ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Materia'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: nuevoClaveMateria,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  onChanged: (value) {
                    nuevoClaveMateria = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoNombre,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  onChanged: (value) {
                    nuevoNombre = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoSemestre.toString(),
                  decoration: InputDecoration(labelText: 'Semestre'),
                  onChanged: (value) {
                    nuevoSemestre = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: nuevoPlanEstudioId.toString(),
                  decoration: InputDecoration(labelText: 'Plan Estudio ID'),
                  onChanged: (value) {
                    nuevoPlanEstudioId = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: nuevoHoraInicio,
                  decoration: InputDecoration(labelText: 'Hora Inicio'),
                  onChanged: (value) {
                    nuevoHoraInicio = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoProfesorRFC,
                  decoration: InputDecoration(labelText: 'Profesor RFC'),
                  onChanged: (value) {
                    nuevoProfesorRFC = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoNumeroControl,
                  decoration: InputDecoration(labelText: 'Numero Control'),
                  onChanged: (value) {
                    nuevoNumeroControl = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoAula,
                  decoration: InputDecoration(labelText: 'Aula'),
                  onChanged: (value) {
                    nuevoAula = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                setState(() {
                  materiasAgregadas[index] = Materia(
                    ClaveMateria: materia.ClaveMateria,
                    NombreMateria: nuevoNombre,
                    Semestre: nuevoSemestre,
                    PlanEstudioId: nuevoPlanEstudioId,
                    HoraInicio: nuevoHoraInicio,
                    ProfesorRFC: nuevoProfesorRFC,
                    NumeroControl: nuevoNumeroControl,
                    aula: nuevoAula,
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
//ya visto
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String nuevoClaveMateria = '';
                  String nuevoNombre = '';
                  int nuevoSemestre = 0;
                  int nuevoPlanEstudioId = 0;
                  String nuevoHoraInicio = '';
                  String nuevoProfesorRFC = '';
                  String nuevoNumeroControl = '';
                  String nuevoAula = '';

                  return StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return AlertDialog(
                        title: Text('Agregar Materia'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Clave De Materia'),
                                onChanged: (value) {
                                  nuevoClaveMateria = value;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Nombre De Materia'),
                                onChanged: (value) {
                                  nuevoNombre = value;
                                },
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Semestre'),
                                onChanged: (value) {
                                  nuevoSemestre = int.parse(value);
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Plan Estudio ID'),
                                onChanged: (value) {
                                  nuevoPlanEstudioId = int.parse(value);
                                },
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Hora Inicio'),
                                onChanged: (value) {
                                  nuevoHoraInicio = value;
                                },
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Profesor RFC'),
                                onChanged: (value) {
                                  nuevoProfesorRFC = value;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Numero Control'),
                                onChanged: (value) {
                                  nuevoNumeroControl = value;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(labelText: 'Aula'),
                                onChanged: (value) {
                                  nuevoAula = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Agregar'),
                            onPressed: () {
                              agregarMateria(
                                Materia(
                                  ClaveMateria: nuevoClaveMateria,
                                  // Se puede ajustar según tu lógica
                                  NombreMateria: nuevoNombre,
                                  Semestre: nuevoSemestre,
                                  PlanEstudioId: nuevoPlanEstudioId,
                                  HoraInicio: nuevoHoraInicio,
                                  ProfesorRFC: nuevoProfesorRFC,
                                  NumeroControl: nuevoNumeroControl,
                                  aula: nuevoAula,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      //a cambiar
     body: materiasAgregadas.isEmpty
          ? Center(child: Text('No hay materias agregadas'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: materiasAgregadas.length,
                itemBuilder: (BuildContext context, int index) {
                  return ExpansionPanelList(
                    children: [
                      ExpansionPanel(
                        headerBuilder:
                            (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                                materiasAgregadas[index].NombreMateria ?? ''),
                            subtitle: Text(
                              'Semestre: ${materiasAgregadas[index].Semestre}, Aula: ${materiasAgregadas[index].aula}',
                            ),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: materiasAgregadas[index].NumeroControl,
                                items: listaNumeroControl.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    materiasAgregadas[index].NumeroControl = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Número de Control',
                                ),
                              ),
                              DropdownButtonFormField<String>(
                                value: materiasAgregadas[index].ProfesorRFC,
                                items: listaRFCMaestro.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    materiasAgregadas[index].ProfesorRFC = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'RFC del Maestro',
                                ),
                              ),
                              DropdownButtonFormField<int>(
                                value: materiasAgregadas[index].PlanEstudioId,
                                items: listaPlanEstudioId.map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    materiasAgregadas[index].PlanEstudioId = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'ID del Plan de Estudio',
                                ),
                              ),
                            ],
                          ),
                        ),
                        isExpanded: true,
                      ),
                    ],

                  
                  );
                },
              ),
            ),
    );
  }
}
class Materia {
  final String? ClaveMateria;
  final String? NombreMateria;
  final int? Semestre;
  String? NumeroControl;
  String? ProfesorRFC;
  int? PlanEstudioId;
  final String? HoraInicio;
  final String? aula;

  Materia({
    required this.ClaveMateria,
    required this.NombreMateria,
    required this.Semestre,
    required this.PlanEstudioId,
    required this.HoraInicio,
    required this.ProfesorRFC,
    required this.NumeroControl,
    required this.aula,
  });

  Map<String, dynamic> toJson() {
    return {
      'ClaveMateria': ClaveMateria,
      'NombreMateria': NombreMateria,
      'Semestre': Semestre,
      'PlanEstudioId': PlanEstudioId,
      'HoraInicio': HoraInicio,
      'ProfesorRFC': ProfesorRFC,
      'NumeroControl': NumeroControl,
      'aula': aula,
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      ClaveMateria: json['ClaveMateria'],
      NombreMateria: json['NombreMateria'],
      Semestre: json['Semestre'],
      PlanEstudioId: json['PlanEstudioId'],
      HoraInicio: json['HoraInicio'],
      ProfesorRFC: json['ProfesorRFC'],
      NumeroControl: json['NumeroControl'],
      aula: json['aula'],
    );
  }
}