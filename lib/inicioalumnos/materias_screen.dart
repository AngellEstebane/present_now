import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  Timer? inasistenciaTimer;
  Position? _currentPosition;
  bool isInAllowedArea = false;

  final List<LatLng> _polygonPoints = [
    LatLng(28.215556, -105.432318),
    LatLng(28.215112, -105.432241),
    LatLng(28.214746, -105.432252),
    LatLng(28.214544, -105.432224),
    LatLng(28.213443, -105.432067),
    LatLng(28.213204, -105.432057),
    LatLng(28.212978, -105.431324),
    LatLng(28.213166, -105.430732),
    LatLng(28.213889, -105.430821),
    LatLng(28.214418, -105.431016),
    LatLng(28.215172, -105.431157),
    LatLng(28.215533, -105.431010),
    LatLng(28.215782, -105.431076),
    LatLng(28.216106, -105.431134),
    LatLng(28.215762, -105.432147),
  ];

  void _showFaltaMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tienes una falta')),
    );
  }

  @override
  void initState() {
    super.initState();
    updateDateTime();
    calculateProgress();
    _getLocation();

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
    progress = currentMinute / 15.0;
  }

  Future<void> _getLocation() async {
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _currentLocation = '${position.latitude}, ${position.longitude}';
      isInAllowedArea = _isPointInPolygon(
        LatLng(position.latitude, position.longitude),
        _polygonPoints,
      );
    });
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length; j++) {
      int i = j - 1;
      if (i < 0) {
        i = polygon.length - 1;
      }

      if (_rayCastIntersect(point, polygon[i], polygon[j])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }
    double m = (aY - bY) / (aX - bX);
    double bee = (-aX) * m + aY;
    double x = (pY - bee) / m;

    return x > pX;
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

            // Cancelar cualquier temporizador de inasistencia existente
            if (inasistenciaTimer != null) {
              inasistenciaTimer!.cancel();
            }

            // Configurar temporizador para inasistencia automática
            if (materiasActuales.isNotEmpty) {
              inasistenciaTimer = Timer(Duration(minutes: 2), () {
                if (!attendanceButtonDisabled) {
                  registerAbsence(authProvider.numeroControl!);
                  _showFaltaMessage();
                  setState(() {
                    attendanceButtonDisabled = true;
                  });
                }
              });
            }

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
                            materiasActuales[currentMateriaIndex]
                                ['NombreMateria']!,
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
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
                  onPressed: attendanceButtonDisabled || !isInAllowedArea
                      ? null
                      : () async {
                          setState(() {
                            attendanceButtonDisabled = true;
                          });
                          //Guardar asistencia
                          saveAttendance(authProvider.numeroControl!, true);
                        },
                  child: const Text('Registrar Asistencia'),
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
                        subtitle: Text(
                            'Clave: ${materia['ClaveMateria']}, Hora: ${materia['Hora']}'),
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

  List<Map<String, String>> _filtrarMateriasPorHora(
      List<Map<String, String>> materias) {
    final ahora = TimeOfDay.now();
    final ahoraEnMinutos = ahora.hour * 60 + ahora.minute;

    return materias.where((materia) {
      final horaInicio = materia['Hora']!;
      final partes = horaInicio.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);
      final horaEnMinutos = hora * 60 + minuto;

      return horaEnMinutos <= ahoraEnMinutos &&
          ahoraEnMinutos < horaEnMinutos + 60;
    }).toList();
  }

  void saveAttendance(String numeroControl, bool presente) async {
    setState(() {
      attendanceButtonDisabled =
          true; // Bloquea el botón cuando se inicia el proceso
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('https://proyecto-agiles.onrender.com/asistencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: jsonEncode({
          'numeroControl': numeroControl,
          'presente': presente,
          'ubicacion': _currentLocation,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia registrada correctamente')),
        );

        // Calcula el tiempo restante hasta que la asistencia deba cambiar a false
        final DateTime now = DateTime.now();
        final DateTime fifteenMinutesLater = now.add(Duration(minutes: 15));
        final Duration timeUntilFalse = fifteenMinutesLater.difference(now);

        // Si la asistencia se registró correctamente, crear un Timer que cambie el valor de presente a false después del tiempo calculado
        Timer(timeUntilFalse, () async {
          final response = await http.post(
            Uri.parse('https://proyecto-agiles.onrender.com/asistencias'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authProvider.token}',
            },
            body: jsonEncode({
              'numeroControl': numeroControl,
              'presente': false,
            }),
          );

          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Asistencia cambiada a false después de 15 minutos')),
            );

            setState(() {
              attendanceButtonDisabled =
                  true; // Bloquea el botón después de 15 minutos
            });
          } else {
            throw Exception('Error al cambiar la asistencia a false');
          }
        });
      } else {
        throw Exception('Error al registrar la asistencia');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        attendanceButtonDisabled =
            false; // Habilita el botón de nuevo si hay un error
      });
    }
  }

  void registerAbsence(String numeroControl) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('https://proyecto-agiles.onrender.com/asistencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: jsonEncode({
          'numeroControl': numeroControl,
          'presente': false,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inasistencia registrada correctamente')),
        );
      } else {
        throw Exception('Error al registrar la inasistencia');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
