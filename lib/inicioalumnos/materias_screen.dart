import 'package:flutter/material.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AsitenciasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Materias Actuales'),
      ),
      body: FutureBuilder(
        future: authProvider
            .cargarMateriasAlumno(), // Cargar las materias del alumno
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Las materias ya han sido cargadas, podemos acceder a ellas directamente desde el AuthProvider
            final materias = authProvider.materias;
            final materiasActuales = _filtrarMateriasPorHora(materias);

            if (materiasActuales.isEmpty) {
              return Center(child: Text('No hay asistencias pendientes'));
            } else {
              return ListView.builder(
                itemCount: materiasActuales.length,
                itemBuilder: (context, index) {
                  final materia = materiasActuales[index];
                  return ListTile(
                    title: Text(materia['NombreMateria']!),
                    subtitle: Text('Clave: ${materia['ClaveMateria']}, Hora: ${materia['Hora']}'),
                    

                  );
                },
              );
            }
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
}
