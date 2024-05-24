import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inicioalumnos/mis_archivos_screen.dart';
import 'inicioalumnos/charlar_screen.dart';
import 'inicioalumnos/materias_screen.dart';
import 'inicioalumnos/avisos_screen.dart';
import 'inicioalumnos/desconectado_screen.dart';
import 'inicioalumnos/justificantes_screen.dart';
import 'inicioalumnos/cerrar_sesion_screen.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InicioAlumnos(),
    );
  }
}

class InicioAlumnos extends StatefulWidget {
  @override
  _InicioAlumnosState createState() => _InicioAlumnosState();
}

class _InicioAlumnosState extends State<InicioAlumnos>
    with TickerProviderStateMixin {
  String currentTime = "";
  String currentDate = "";
  int currentMateriaIndex = 0;
  double progress = 0.0;
  late AnimationController progressController;
  Color barColor = Colors.blue;
  List<Color> materiaColors = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue
  ];
  List<String> materiaTimes = [
    "08:00 AM",
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "01:00 PM"
  ]; // Horas personalizadas para cada materia

  List<String> materias = [
    "Materia 1",
    "Materia 2",
    "Materia 3",
    "Materia 4",
    "Materia 5",
    "Materia 6"
  ];
  bool showAttendance = false;
  bool daySaved = false;
  bool attendanceButtonDisabled =
      false; // Variable para controlar si el botón de asistencia está bloqueado

  @override
  void initState() {
    super.initState();
    updateDateTime();
    calculateProgress();

    progressController = AnimationController(
      vsync: this,
      duration: Duration(minutes: 60),
    );

    progressController.forward();

    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        updateDateTime();
        calculateProgress();
      });

      if (DateTime.now().minute == 0) {
        progressController.reset();
        progressController.forward();
        // Cambiar de materia
        setState(() {
          currentMateriaIndex = (currentMateriaIndex + 1) % materias.length;
          // Restablecer el color de la materia a azul cuando cambia de materia
          for (int i = 0; i < materiaColors.length; i++) {
            materiaColors[i] = Colors.blue;
          }
        });
        // Guardar el día
        if (!daySaved) {
          daySaved = true;
          saveDay();
          // Guardar inasistencia al inicio del día si no hay asistencia registrada
          if (!showAttendance) {
            saveAttendance(true, false);
          }
        }

        // Activar el botón de asistencia después de que cambie la hora
        setState(() {
          attendanceButtonDisabled = false;
        });
      } else {
        daySaved = false; // Restablecer la bandera para guardar el día
      }
    });
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  void calculateProgress() {
    int currentMinute = DateTime.now().minute;
    progress = currentMinute / 60.0;

    // Actualizar el índice de la materia actual según la hora del día
    int hour = DateTime.now().hour;
    if (hour >= 8 && hour <= 13) {
      currentMateriaIndex = hour - 8;
    } else {
      currentMateriaIndex = -1; // Fuera del horario de las materias
    }

    // Verificar si el horario actual está dentro del rango de alguna materia
    if (currentMateriaIndex >= 0 && currentMateriaIndex < materias.length) {
      if (currentMinute < 15) {
        barColor = Colors.green;
        materiaColors[currentMateriaIndex] = Colors.green;
      } else if (currentMinute >= 15 && currentMinute <= 20) {
        barColor = Colors.yellow; // Cambiado a amarillo en lugar de azul
        materiaColors[currentMateriaIndex] = Colors.yellow;
      } else if (currentMinute > 20 && currentMinute < 60) {
        barColor = Colors.red;
        materiaColors[currentMateriaIndex] = Colors.red;
      } else {
        barColor = Colors.blue; // Restablecer a azul fuera del rango de tiempo
        materiaColors[currentMateriaIndex] = Colors.blue;
      }
    } else {
      // Si no hay ninguna materia programada para el horario actual, restablecer a azul
      barColor = Colors.blue;
    }
  }

  void updateDateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
      currentDate = DateFormat('EEEE dd/MM/yyyy').format(DateTime.now());
    });
  }

  void saveDay() {
    // Implementa aquí la lógica para guardar el día actual
    print('Día guardado: $currentDate');
  }

  void saveAttendance(bool isLate, bool isPresent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Guardar el registro de asistencia
    String key = "${currentDate}_${materias[currentMateriaIndex]}";

    // Verificar si no se mandó ninguna asistencia para marcar como inasistencia
    if (!isLate && !isPresent) {
      isPresent = false; // Marcar como inasistencia
    }

    prefs.setBool(
        key, isPresent); // true para asistencia, false para inasistencia
  }

  void _getLocation() async {
    // Verificar si el usuario ha otorgado permiso para acceder a la ubicación
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio de ubicación no está habilitado, solicitar al usuario que lo habilite
      bool serviceStatus = await Geolocator.openLocationSettings();
      if (!serviceStatus) {
        // El usuario no habilitó el servicio de ubicación, mostrar un mensaje o tomar otra acción según sea necesario
        return;
      }
    }

    // Verificar si se ha otorgado el permiso de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si el permiso de ubicación está denegado, solicitar al usuario que lo habilite
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // El usuario negó el permiso de ubicación, mostrar un mensaje o tomar otra acción según sea necesario
        return;
      }
    }

    // Obtener la ubicación actual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Actualizar la interfaz de usuario con la ubicación obtenida
    setState(() {
      // Aquí puedes mostrar la ubicación en la interfaz de usuario
      print('Ubicación actual: ${position.latitude}, ${position.longitude}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Present Now'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('URL_DE_TU_FOTO'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    authProvider.nombreAlumno.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authProvider.numeroControl.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Mis archivos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisArchivosScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Charlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CharlarScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Materias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MateriasScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Avisos recientes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvisosScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Modo desconectado'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DesconectadoScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Justificantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JustificantesScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CerrarSesionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    currentDate,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Spacer(),
                  Text(currentTime),
                ],
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recordatorios de Materias',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(height: 5.0),
                      for (var i = 0; i < materias.length; i++)
                        ListTile(
                          title: Text(
                            '${materias[i]}: ${materiaTimes[i]}', // Mostrar la hora personalizada para cada materia
                            style: TextStyle(
                              color: materiaColors[i], // Color de la materia
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              if (currentMateriaIndex >= 0 && showAttendance)
                Container(
                  color: currentMateriaIndex < materias.length
                      ? materiaColors[currentMateriaIndex]
                      : Colors.grey,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    currentMateriaIndex < materias.length
                        ? materias[currentMateriaIndex]
                        : 'Todavía no ha comenzado el día',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (attendanceButtonDisabled) return;

                      if (showAttendance) {
                        // Si ya se ha registrado la asistencia, cambiar el color de la materia a azul
                        setState(() {
                          materiaColors[currentMateriaIndex] = Colors.blue;
                          showAttendance = false;
                        });
                      } else {
                        // Código existente para registrar la asistencia
                        if (!showAttendance) {
                          // Calcular el progreso y actualizar los colores de las materias
                          calculateProgress();

                          // Verificar el intervalo de tiempo y actualizar los colores de las materias
                          if (DateTime.now().minute <= 15 &&
                              currentMateriaIndex >= 0) {
                            // Cambiar el color de la barra y el recuadro de la materia a verde
                            setState(() {
                              materiaColors[currentMateriaIndex] = Colors.green;
                              showAttendance = true;
                            });
                            // Mostrar mensaje de éxito en el registro de asistencia con retraso de 2 segundos
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Éxito en registrar asistencia'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            });
                          } else if (DateTime.now().minute > 15 &&
                              DateTime.now().minute <= 20 &&
                              currentMateriaIndex >= 0) {
                            // Cambiar el color de la barra y el recuadro de la materia a amarillo
                            setState(() {
                              materiaColors[currentMateriaIndex] =
                                  Colors.yellow;
                              showAttendance = true;
                            });
                            // Mostrar mensaje de asistencia registrada con retraso de 2 segundos
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Asistencia registrada con retraso'),
                                  backgroundColor: Colors.yellow,
                                ),
                              );
                            });
                          } else if (DateTime.now().minute > 20 &&
                              currentMateriaIndex >= 0) {
                            // Cambiar el color de la barra y el recuadro de la materia a rojo
                            setState(() {
                              materiaColors[currentMateriaIndex] = Colors.red;
                              showAttendance = true;
                            });
                            // Mostrar mensaje de error en el registro de asistencia con retraso de 2 segundos
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error al registrar asistencia'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          }

                          // Desactivar el botón de asistencia después de hacer clic
                          setState(() {
                            attendanceButtonDisabled = true;
                          });
                        }
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: showAttendance ? Colors.grey : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Asistencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ubicación actual: (COORDENADAS)',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          _getLocation, // Llamar a la función para obtener la ubicación
                      child: Text('Actualizar Ubicación'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
