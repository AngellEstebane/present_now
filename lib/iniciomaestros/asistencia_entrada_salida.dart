import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/providers/auth_provider.dart';

class AsistenciaEntradaSalida extends StatefulWidget {
  @override
  _AsistenciaEntradaSalidaState createState() => _AsistenciaEntradaSalidaState();
}

class _AsistenciaEntradaSalidaState extends State<AsistenciaEntradaSalida> {
  String currentTime = "";
  String currentDate = "";
  bool attendanceButtonDisabled = false;
  String _currentLocation = 'Coordenadas no disponibles';
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

  @override
  void initState() {
    super.initState();
    updateDateTime();
    _getLocation();

    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        updateDateTime();
      });
    });
  }

  void updateDateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
      currentDate = DateFormat('EEEE dd/MM/yyyy').format(DateTime.now());
    });
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
    return ((intersectCount % 2) == 1); // impar = dentro, par = fuera
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
        title: const Text('Asistencia Entrada y Salida'),
      ),
      body: FutureBuilder(
        future: authProvider.cargarMateriasProfesor(),
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
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Text(
                  currentTime,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 20),
                materiasActuales.isNotEmpty
                    ? Column(
                        children: [
                          const Text(
                            'Materia actual:',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            materiasActuales[0]['NombreMateria']!,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const Text(
                        'Fuera del horario de clases',
                        style: TextStyle(fontSize: 20),
                      ),
                const SizedBox(height: 20),
                const Text(
                  'Ubicación actual:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _currentLocation,
                  style: const TextStyle(fontSize: 16),
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
                        trailing: Column(
                          children: [
                            ElevatedButton(
                              onPressed: attendanceButtonDisabled || !isInAllowedArea
                                  ? null
                                  : () async {
                                      setState(() {
                                        attendanceButtonDisabled = true;
                                      });
                                      // Guardar asistencia de entrada
                                      saveAttendance(
                                          authProvider.rfc!,
                                          true,
                                          materia['ClaveMateria']!,
                                          'entrada');
                                    },
                              child: Text(isInAllowedArea
                                  ? 'Registrar Entrada'
                                  : 'Fuera del área permitida'),
                            ),
                            ElevatedButton(
                              onPressed: attendanceButtonDisabled || !isInAllowedArea
                                  ? null
                                  : () async {
                                      setState(() {
                                        attendanceButtonDisabled = true;
                                      });
                                      // Guardar asistencia de salida
                                      saveAttendance(
                                          authProvider.rfc!,
                                          true,
                                          materia['ClaveMateria']!,
                                          'salida');
                                    },
                              child: Text(isInAllowedArea
                                  ? 'Registrar Salida'
                                  : 'Fuera del área permitida'),
                            ),
                          ],
                        ),
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

  void saveAttendance(
      String rfc, bool presente, String idMateria, String tipo) async {
    setState(() {
      attendanceButtonDisabled = true; // Bloquea el botón cuando se inicia el proceso
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('https://proyecto-agiles.onrender.com/entrada/profesor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: jsonEncode({
          'rfc': rfc,
          'presente': presente,
          'id_materia': idMateria,
          'ubicacion': _currentLocation,
          'tipo': tipo,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia de $tipo registrada correctamente')),
        );
      } else {
        throw Exception('Error al registrar la asistencia de $tipo');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        attendanceButtonDisabled = false; // Habilita el botón nuevamente
      });
    }
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
