import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  // Lista de materias agregadas por el usuario
  List<Materia> materiasAgregadas = [];

  // Controladores para los campos de texto
  TextEditingController nombreController =
      TextEditingController(text: 'Nombre');
  TextEditingController grupoController = TextEditingController(text: 'Grupo');
  TextEditingController gradoController = TextEditingController(text: 'Grado');
  TextEditingController maestroController =
      TextEditingController(text: 'Maestro');
  TimeOfDay? selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    cargarMaterias(); // Cargar materias al inicializar el widget
  }

  // Guarda las materias en SharedPreferences
  Future<void> guardarMaterias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> materiasJson = materiasAgregadas
        .map((materia) => jsonEncode(materia.toJson()))
        .toList();
    await prefs.setStringList(
        'materias', materiasJson); // Cambio de clave a 'materias'
  }

  // Carga las materias desde SharedPreferences
  Future<void> cargarMaterias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? materiasJson =
        prefs.getStringList('materias'); // Cambio de clave a 'materias'
    if (materiasJson != null) {
      setState(() {
        materiasAgregadas = materiasJson
            .map((json) => Materia.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  // Función para agregar una nueva materia a la lista
  void agregarMateria(Materia materia) {
    setState(() {
      materiasAgregadas.add(materia);
      guardarMaterias(); // Guardar materias al agregar una nueva
    });
  }

  // Función para eliminar una materia de la lista
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
                  guardarMaterias(); // Guardar materias al eliminar una
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función para editar una materia
  void editarMateria(Materia materia, int index) async {
    String nuevoNombre = materia.nombre ?? '';
    String nuevoGrupo = materia.grupo ?? '';
    String nuevoGrado = materia.grado ?? '';
    String nuevoMaestro = materia.maestro ?? '';
    TimeOfDay? nuevoHorario = materia.horario;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Materia'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: nuevoNombre,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  onChanged: (value) {
                    nuevoNombre = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoGrado,
                  decoration: InputDecoration(labelText: 'Grado'),
                  onChanged: (value) {
                    nuevoGrado = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoGrupo,
                  decoration: InputDecoration(labelText: 'Grupo'),
                  onChanged: (value) {
                    nuevoGrupo = value;
                  },
                ),
                TextFormField(
                  initialValue: nuevoMaestro,
                  decoration: InputDecoration(labelText: 'Maestro'),
                  onChanged: (value) {
                    nuevoMaestro = value;
                  },
                ),
                ListTile(
                  title: Text('Hora'),
                  subtitle: Text(
                    '${nuevoHorario?.hour}:00',
                  ),
                  onTap: () async {
                    // Mostrar un cuadro de diálogo para seleccionar la hora
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: nuevoHorario ?? TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        // Fijar los minutos en 00
                        nuevoHorario =
                            TimeOfDay(hour: pickedTime.hour, minute: 0);
                      });
                    }
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
                    nombre: nuevoNombre,
                    grupo: nuevoGrupo,
                    grado: nuevoGrado,
                    maestro: nuevoMaestro,
                    horario: nuevoHorario,
                  );
                  guardarMaterias(); // Guardar materias al editar
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función para agregar un alumno a la materia
  void agregarAlumno(Materia materia) async {
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
                decoration: InputDecoration(labelText: 'No De Control'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Muestra un cuadro de diálogo para agregar una nueva materia
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String nuevoNombre = '';
                  String nuevoGrupo = '';
                  String nuevoGrado = '';
                  String nuevoMaestro = '';

                  return StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return AlertDialog(
                        title: Text('Agregar Materia'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: nuevoNombre,
                                decoration:
                                    InputDecoration(labelText: 'Nombre'),
                                onChanged: (value) {
                                  nuevoNombre = value;
                                },
                              ),
                              TextFormField(
                                initialValue: nuevoGrado,
                                decoration: InputDecoration(labelText: 'Grado'),
                                onChanged: (value) {
                                  nuevoGrado = value;
                                },
                              ),
                              TextFormField(
                                initialValue: nuevoGrupo,
                                decoration: InputDecoration(labelText: 'Grupo'),
                                onChanged: (value) {
                                  nuevoGrupo = value;
                                },
                              ),
                              TextFormField(
                                initialValue: nuevoMaestro,
                                decoration:
                                    InputDecoration(labelText: 'Maestro'),
                                onChanged: (value) {
                                  nuevoMaestro = value;
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
                              // Agrega una nueva materia a la lista
                              agregarMateria(
                                Materia(
                                  nombre: nuevoNombre.isNotEmpty
                                      ? nuevoNombre
                                      : 'Nombre',
                                  grupo: nuevoGrupo.isNotEmpty
                                      ? nuevoGrupo
                                      : 'Grupo',
                                  grado: nuevoGrado.isNotEmpty
                                      ? nuevoGrado
                                      : 'Grado',
                                  maestro: nuevoMaestro.isNotEmpty
                                      ? nuevoMaestro
                                      : 'Maestro',
                                  horario: TimeOfDay
                                      .now(), // Establecer horario a la hora actual
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
      body: materiasAgregadas.isEmpty
          ? Center(
              child: Text('No hay materias agregadas'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: materiasAgregadas.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(materiasAgregadas[index].nombre ?? ''),
                        ),
                        IconButton(
                          icon: Icon(Icons.person_add),
                          onPressed: () {
                            // Agregar alumno al hacer clic en el botón
                            agregarAlumno(materiasAgregadas[index]);
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(
                        'Grado: ${materiasAgregadas[index].grado ?? ''}, Grupo: ${materiasAgregadas[index].grupo ?? ''}, Maestro: ${materiasAgregadas[index].maestro ?? ''}'),
                    onTap: () {
                      // Editar la materia al hacer clic
                      editarMateria(materiasAgregadas[index], index);
                    },
                  );
                },
              ),
            ),
    );
  }
}

class Materia {
  final String? nombre;
  final String? grupo;
  final String? grado;
  final String? maestro;
  final TimeOfDay? horario;

  Materia({
    required this.nombre,
    required this.grupo,
    required this.grado,
    required this.maestro,
    required this.horario,
  });

  // Convertir Materia a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'grupo': grupo,
      'grado': grado,
      'maestro': maestro,
      'horario': horario?.toString(),
    };
  }

  // Crear Materia desde JSON
  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      nombre: json['nombre'],
      grupo: json['grupo'],
      grado: json['grado'],
      maestro: json['maestro'],
      horario: TimeOfDay.now(), // Establecer horario a la hora actual
    );
  }
}

class Alumno {
  final String nombre;
  final String noDeControl;

  Alumno({
    required this.nombre,
    required this.noDeControl,
  });

  // Convertir Alumno a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'noDeControl': noDeControl,
    };
  }
}

