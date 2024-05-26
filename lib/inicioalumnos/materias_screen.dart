import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class AsitenciasScreen extends StatefulWidget {
  @override
  _AsitenciasScreenState createState() => _AsitenciasScreenState();
}

class _AsitenciasScreenState extends State<AsitenciasScreen> {
  String currentTime = "";
  String currentDate = "";
  int currentMateriaIndex = 0;
  double progress = 0.0;
  Color barColor = Colors.blue;
  bool attendanceButtonDisabled = false;
  String _currentLocation = 'Coordenadas no disponibles';

  @override
  void initState() {
    super.initState();
    updateDateTime();
    calculateProgress();

    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        updateDateTime();
        calculateProgress();
      });
    });
  }

  void updateDateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
      currentDate = DateFormat('EEEE dd/MM/yyyy').format(DateTime.now());
    });
  }

  void calculateProgress() {
    int currentMinute = DateTime.now().minute;
    progress = currentMinute / 60.0;
  }

  void _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool serviceStatus = await Geolocator.openLocationSettings();
      if (!serviceStatus) {
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = '${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Materias Actuales'),
      ),
      body: FutureBuilder(
        future: authProvider.cargarMateriasAlumno(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final materias = authProvider.materias;
            final materiasActuales = _filtrarMateriasPorHora(materias);

            return Column(
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
                materiasActuales.isNotEmpty && currentMateriaIndex >= 0
                    ? Column(
                        children: [
                          Text(
                            'Materia actual:',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            materiasActuales[currentMateriaIndex]['NombreMateria']!,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                          });
                          // Guardar asistencia
                          saveAttendance(false, true);
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
                Expanded(
                  child: ListView.builder(
                    itemCount: materiasActuales.length,
                    itemBuilder: (context, index) {
                      final materia = materiasActuales[index];
                      return ListTile(
                        title: Text(materia['NombreMateria']!),
                        subtitle: Text('Clave: ${materia['ClaveMateria']}, Hora: ${materia['Hora']}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Map<String, String>> _filtrarMateriasPorHora(List<Map<String, String>> materias) {
    final ahora = TimeOfDay.now();
    final ahoraEnMinutos = ahora.hour * 60 + ahora.minute;

    return materias.where((materia) {
      final horaInicio = materia['Hora']!;
      final partes = horaInicio.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);
      final horaEnMinutos = hora * 60 + minuto;

      return horaEnMinutos <= ahoraEnMinutos && ahoraEnMinutos < horaEnMinutos + 60;
    }).toList();
  }

  void saveAttendance(bool isLate, bool isPresent) async {
    // Implement your logic to save attendance here
    print('Asistencia guardada: $isPresent');
  }
}
