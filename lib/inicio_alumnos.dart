import 'dart:async'; // Para usar temporizadores y otros objetos asíncronos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y horas
import 'package:shared_preferences/shared_preferences.dart'; // Para almacenar datos localmente
import 'inicioalumnos/mis_archivos_screen.dart'; // Importación de pantallas
import 'inicioalumnos/charlar_screen.dart';
import 'inicioalumnos/materias_screen.dart';
import 'inicioalumnos/avisos_screen.dart';
import 'inicioalumnos/desconectado_screen.dart';
import 'inicioalumnos/justificantes_screen.dart';
import 'inicioalumnos/cerrar_sesion_screen.dart';
import 'package:geolocator/geolocator.dart'; // Para manejar la geolocalización

import 'package:provider/provider.dart'; // Para el manejo del estado
import 'providers/materia_provider.dart'; // Proveedor de datos de materias

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MateriaProvider()), // Inicializa el proveedor de materias
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InicioAlumnos(), // Pantalla principal de la aplicación
    );
  }
}

class InicioAlumnos extends StatefulWidget {
  @override
  _InicioAlumnosState createState() => _InicioAlumnosState();
}

class _InicioAlumnosState extends State<InicioAlumnos>
    with TickerProviderStateMixin {
  String currentTime = ""; // Almacena la hora actual
  String currentDate = ""; // Almacena la fecha actual
  int currentMateriaIndex = 0; // Índice de la materia actual
  double progress = 0.0; // Progreso de la barra de progreso
  late AnimationController
      progressController; // Controlador de animación para la barra de progreso
  Color barColor = Colors.blue; // Color de la barra de progreso
  List<Color> materiaColors =
      List.generate(6, (index) => Colors.blue); // Colores para cada materia

  bool showAttendance = false; // Controla la visualización de la asistencia
  bool daySaved = false; // Indica si el día ha sido guardado
  bool attendanceButtonDisabled =
      false; // Controla el estado del botón de asistencia

  @override
  void initState() {
    super.initState();
    updateDateTime(); // Actualiza la fecha y la hora
    calculateProgress(); // Calcula el progreso de la barra

    // Configura el controlador de animación para una duración de 60 minutos
    progressController = AnimationController(
      vsync: this,
      duration: Duration(minutes: 60),
    );

    progressController.forward(); // Inicia la animación

    // Configura un temporizador para actualizar la hora y el progreso cada minuto
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        updateDateTime(); // Actualiza la hora actual
        calculateProgress(); // Recalcula el progreso de la barra
      });

      // Si es el primer minuto de una nueva hora
      if (DateTime.now().minute == 0) {
        progressController.reset(); // Reinicia la animación
        progressController.forward(); // Vuelve a iniciar la animación
        setState(() {
          currentMateriaIndex = (currentMateriaIndex + 1) %
              6; // Actualiza el índice de la materia
          for (int i = 0; i < materiaColors.length; i++) {
            materiaColors[i] =
                Colors.blue; // Resetea los colores de las materias
          }
        });
        if (!daySaved) {
          daySaved = true; // Marca el día como guardado
          saveDay(); // Guarda el día
          if (!showAttendance) {
            saveAttendance(true, false); // Guarda la asistencia
          }
        }
        setState(() {
          attendanceButtonDisabled = false; // Habilita el botón de asistencia
        });
      } else {
        daySaved = false; // Marca el día como no guardado
      }
    });
  }

  @override
  void dispose() {
    progressController.dispose(); // Libera el controlador de animación
    super.dispose();
  }

  void calculateProgress() {
    int currentMinute = DateTime.now().minute; // Obtiene el minuto actual
    progress =
        currentMinute / 60.0; // Calcula el progreso en base al minuto actual

    int hour = DateTime.now().hour; // Obtiene la hora actual
    if (hour >= 8 && hour <= 13) {
      currentMateriaIndex = hour - 8; // Calcula el índice de la materia actual
    } else {
      currentMateriaIndex = -1; // Si no está en el rango, asigna -1
    }

    // Cambia los colores de la barra y de las materias según el minuto actual
    if (currentMateriaIndex >= 0 && currentMateriaIndex < 6) {
      if (currentMinute < 15) {
        barColor = Colors.green;
        materiaColors[currentMateriaIndex] = Colors.green;
      } else if (currentMinute >= 15 && currentMinute <= 20) {
        barColor = Colors.yellow;
        materiaColors[currentMateriaIndex] = Colors.yellow;
      } else if (currentMinute > 20 && currentMinute < 60) {
        barColor = Colors.red;
        materiaColors[currentMateriaIndex] = Colors.red;
      } else {
        barColor = Colors.blue;
        materiaColors[currentMateriaIndex] = Colors.blue;
      }
    } else {
      barColor = Colors.blue; // Si no está en el rango, asigna el color azul
    }
  }

  void updateDateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a')
          .format(DateTime.now()); // Actualiza la hora actual
      currentDate = DateFormat('EEEE dd/MM/yyyy')
          .format(DateTime.now()); // Actualiza la fecha actual
    });
  }

  void saveDay() {
    print(
        'Día guardado: $currentDate'); // Imprime el día guardado en la consola
  }

  void saveAttendance(bool isLate, bool isPresent) async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Obtiene una instancia de SharedPreferences
    String key =
        "${currentDate}_${Provider.of<MateriaProvider>(context, listen: false).materias[currentMateriaIndex].nombreMateria}"; // Crea una clave única para la asistencia

    if (!isLate && !isPresent) {
      isPresent = false; // Si no está tarde ni presente, asigna falso
    }

    prefs.setBool(
        key, isPresent); // Guarda el estado de asistencia en SharedPreferences
  }

  void _getLocation() async {
    bool serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); // Verifica si el servicio de ubicación está habilitado
    if (!serviceEnabled) {
      bool serviceStatus = await Geolocator
          .openLocationSettings(); // Abre la configuración de ubicación si no está habilitada
      if (!serviceStatus) {
        return;
      }
    }

    LocationPermission permission = await Geolocator
        .checkPermission(); // Verifica los permisos de ubicación
    if (permission == LocationPermission.denied) {
      permission = await Geolocator
          .requestPermission(); // Solicita permisos si están denegados
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Obtiene la ubicación actual

    setState(() {
      print(
          'Ubicación actual: ${position.latitude}, ${position.longitude}'); // Imprime la ubicación actual en la consola
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Present Now'), // Título de la barra de la aplicación
        backgroundColor:
            Colors.blue, // Color de fondo de la barra de la aplicación
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Color de fondo del encabezado del cajón
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'URL_DE_TU_FOTO'), // Imagen de perfil del usuario
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nombre del Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Correo Institucional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Agrega tus elementos ListTile aquí
            ListTile(
              title: Text('Mis archivos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MisArchivosScreen()), // Navega a
                ); // Navega a la pantalla de "Mis archivos"
              },
            ),
            ListTile(
              title: Text('Charlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CharlarScreen()), // Navega a la pantalla de "Charlar"
                );
              },
            ),
            ListTile(
              title: Text('Materias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MateriasScreen()), // Navega a la pantalla de "Materias"
                );
              },
            ),
            ListTile(
              title: Text('Avisos recientes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AvisosScreen()), // Navega a la pantalla de "Avisos recientes"
                );
              },
            ),
            ListTile(
              title: Text('Modo desconectado'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DesconectadoScreen()), // Navega a la pantalla de "Modo desconectado"
                );
              },
            ),
            ListTile(
              title: Text('Justificantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          JustificantesScreen()), // Navega a la pantalla de "Justificantes"
                );
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CerrarSesionScreen()), // Navega a la pantalla de "Cerrar sesión"
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<MateriaProvider>(
        builder: (context, materiaProvider, child) {
          if (materiaProvider.isLoading) {
            return Center(
                child:
                    CircularProgressIndicator()); // Muestra un indicador de carga si los datos están cargando
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentDate,
                        style: TextStyle(
                            fontSize: 20.0), // Muestra la fecha actual
                      ),
                      Spacer(),
                      Text(currentTime), // Muestra la hora actual
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey), // Contenedor con borde gris
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recordatorios de Materias',
                            style: TextStyle(
                                fontSize:
                                    20.0), // Título de los recordatorios de materias
                          ),
                          SizedBox(height: 5.0),
                          for (var i = 0;
                              i < materiaProvider.materias.length;
                              i++) // Itera sobre las materias
                            ListTile(
                              title: Text(materiaProvider.materias[i]
                                  .nombreMateria), // Nombre de la materia
                              subtitle: Text(materiaProvider.materias[i]
                                  .horaInicio), // Hora de inicio de la materia
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
