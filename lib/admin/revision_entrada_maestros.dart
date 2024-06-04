import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListAsistenciaMaestros extends StatefulWidget {
  @override
  _ListAsistenciaMaestrosState createState() => _ListAsistenciaMaestrosState();
}

class _ListAsistenciaMaestrosState extends State<ListAsistenciaMaestros> {
  List<MaestrosResponse> asistencias = [];
  bool isLoading = true;
  DateTime? selectedDate;
  final dateController = TextEditingController();
  final aulaController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
    _timer = Timer.periodic(Duration(minutes: 1),
        (Timer t) => fetchAsistencias()); // Actualiza cada minuto
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAsistencias({String? date, String? aula}) async {
    String url = 'https://proyecto-agiles.onrender.com/entrada/profesor';
    if (date != null) {
      url =
          'https://proyecto-agiles.onrender.com/entrada/profesorfecha?fecha=$date';
    } else if (aula != null) {
      url =
          'https://proyecto-agiles.onrender.com/entrada/profesoraula?aula=$aula';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse); // Agrega esto para ver los datos en la consola
      setState(() {
        asistencias = jsonResponse
            .map((data) => MaestrosResponse.fromJson(data))
            .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load asistencias');
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.toLocal()}".split(' ')[0];
        fetchAsistencias(date: dateController.text);
      });
    }
  }

  void _searchByAula() {
    String aula = aulaController.text;
    if (aula.isNotEmpty) {
      fetchAsistencias(aula: aula);
    }
  }

  Future<void> _updateAsistencia(
      MaestrosResponse asistencia, bool entro) async {
    final formattedDate = asistencia.fechaHora.toIso8601String().split('T')[0];
    final url =
        'https://proyecto-agiles.onrender.com/entrada/profesorcheck/$formattedDate';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entro': entro}),
    );

    if (response.statusCode == 200) {
      print('Asistencia actualizada exitosamente');
      setState(() {
        asistencia.entro = entro; // Actualizar el valor de entro
      });
    } else {
      print(
          'Error al actualizar la asistencia: ${response.statusCode}'); // Agrega esto para ver el error en la consola
      throw Exception('Failed to update asistencia');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 24, 81, 180), // solo azul
        foregroundColor: Colors.white,
        title: Text('Lista de Entrada de Maestros'),

        elevation: 2,
        shadowColor: Colors.transparent,
        centerTitle: true,
        clipBehavior: Clip.hardEdge,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 24, 81, 180),
              const Color.fromARGB(255, 26, 87, 136).withOpacity(0.5)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: "Seleccionar Fecha",
                  labelStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: aulaController,
                decoration: InputDecoration(
                  labelText: "Buscar por Aula",
                  labelStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.search),
                    onPressed: _searchByAula,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: asistencias.length,
                      itemBuilder: (context, index) {
                        final asistencia = asistencias[index];
                        return Card(
                          child: ListTile(
                            title:
                                Text('Profesor RFC: ${asistencia.profesorRfc}'),
                            subtitle: Text(
                                'Aula: ${asistencia.aula}\nFecha: ${asistencia.fechaHora}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(asistencia.entro
                                    ? 'Asistió'
                                    : 'No asistió'),
                                Switch(
                                  value: asistencia.entro,
                                  onChanged: (bool newValue) {
                                    _updateAsistencia(asistencia, newValue);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaestrosResponse {
  final int id;
  final String profesorRfc;
  final String aula;
  final DateTime fechaHora;
  bool entro; // Cambiar el tipo de entro a booleano

  MaestrosResponse({
    required this.id,
    required this.profesorRfc,
    required this.aula,
    required this.fechaHora,
    required this.entro, // No inicializar aquí, se debe inicializar en fromJson
  });

  factory MaestrosResponse.fromJson(Map<String, dynamic> json) {
    return MaestrosResponse(
      id: json['id'],
      profesorRfc: json['ProfesorRFC'],
      aula: json['aula'],
      fechaHora: DateTime.parse(json['fechaConHora']),
      entro: json['Entro'] == 1, // Convertir el valor numérico a booleano
    );
  }
}
