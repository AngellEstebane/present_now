import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Importa el paquete path_provider

class ConsultaInasistencias extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta de Inasistencias'),
      ),
      body: FutureBuilder<List<String>>(
        future: _readInasistenciasFile(),
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

  Future<List<String>> _readInasistenciasFile() async {
    final String currentDateFormatted =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String inasistenciaFilePath =
        await _getFilePath('inasistencia_$currentDateFormatted.txt');

    try {
      File inasistenciaFile = File(inasistenciaFilePath);
      List<String> lines = await inasistenciaFile.readAsLines();
      return lines;
    } catch (e) {
      print('Error al leer el archivo de inasistencias: $e');
      return [];
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}
