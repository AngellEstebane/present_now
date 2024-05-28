import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inicioalumnos/materias_screen.dart';
import 'inicioalumnos/justificantes_screen.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
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

  List<String> materias = [];
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

  String _currentLocation = 'Coordenadas no disponibles';
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
      _currentLocation = '${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Present Now'),
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
                  SizedBox(height: 6),
                  Text(
                    '¡Bienvenido a Present Now!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    authProvider.nombreAlumno.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    authProvider.numeroControl.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Asistencias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AsitenciasScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
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
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                bool? confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmación'),
                        content:
                            const Text('¿Seguro que quieres cerrar sesión?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); //Cancelar
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); //Confirmar
                            },
                            child: const Text('Cerrar sesión'),
                          )
                        ],
                      );
                    });
                if (confirmLogout == true) {
                  // Obtener instancia de AuthProvider y llamar al método logout
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    'login',
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: FadeInDown(
          duration: const Duration(milliseconds: 700),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Estamos encantados de tenerte aquí.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
