import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DesconectadoScreen(),
    );
  }
}

class DesconectadoScreen extends StatefulWidget {
  @override
  _DesconectadoScreenState createState() => _DesconectadoScreenState();
}

class _DesconectadoScreenState extends State<DesconectadoScreen>
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

  void saveAttendanceLocally() async {
    // Guardar el estado de la asistencia localmente
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asistencia_${DateTime.now().toString()}', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modo Desconectado'),
        backgroundColor: Colors.blue,
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para el botón de asistencia (si es necesario)
                      saveAttendanceLocally(); // Guardar la asistencia localmente
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
            ],
          ),
        ),
      ),
    );
  }
}
