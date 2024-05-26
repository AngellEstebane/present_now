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
                  SizedBox(height: 45),
                  Text(
                    authProvider.nombreAlumno.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    authProvider.numeroControl.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'present.now.2023@gmail.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Mis Archivos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisArchivosScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Charlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CharlarScreen()),
                );
              },
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
              leading: Icon(Icons.announcement),
              title: Text('Avisos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvisosScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.wifi_off),
              title: Text('Desconectado'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DesconectadoScreen()),
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
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar Sesión'),
              onTap: () async {
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CerrarSesionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentDate,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            currentTime,
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 20),
          materias.isNotEmpty && currentMateriaIndex >= 0
              ? Column(
                  children: [
                    Text(
                      'Materia actual:',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      materias[currentMateriaIndex],
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ],
                )
              : Text(
                  'Fuera del horario de clases',
                  style: TextStyle(fontSize: 20),
                ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: attendanceButtonDisabled
                ? null
                : () {
                    _getLocation();
                    setState(() {
                      attendanceButtonDisabled = true;
                      showAttendance = true;
                      // Guardar asistencia
                      saveAttendance(false, true);
                    });
                  },
            child: Text('Registrar Asistencia'),
          ),
          SizedBox(height: 20),
          Text(
            'Ubicación actual:',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            _currentLocation,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
