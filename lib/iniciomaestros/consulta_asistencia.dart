import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Importa el paquete path_provider

class ConsultaAsistencia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta de Asistencia'),
      ),
      body: FutureBuilder<List<String>>(
        future: _readAsistenciaFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los datos'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<List<String>> _readAsistenciaFile() async {
    final String currentDateFormatted =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String asistenciaFilePath =
        await _getFilePath('asistencia_$currentDateFormatted.txt');

    try {
      File asistenciaFile = File(asistenciaFilePath);
      List<String> lines = await asistenciaFile.readAsLines();
      return lines;
    } catch (e) {
      print('Error al leer el archivo de asistencia: $e');
      return [];
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}
