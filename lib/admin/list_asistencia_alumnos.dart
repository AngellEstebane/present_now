import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/admin/models/asistencia_alumno_model.dart';

class ListAsistenciaAlumnos extends StatefulWidget {
  @override
  _ListAsistenciaAlumnosState createState() => _ListAsistenciaAlumnosState();
}

class _ListAsistenciaAlumnosState extends State<ListAsistenciaAlumnos> {
  List<AsistenciaAlumnoModel>? asistencias;
  bool isLoading = true;
  DateTime? selectedDate;
  String? selectedMateriaId;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
  }

  Future<void> fetchAsistencias() async {
    final response = await http.get(Uri.parse('https://proyecto-agiles.onrender.com/asistencias'));

    if (response.statusCode == 200) {
      setState(() {
        asistencias = asistenciaAlumnoModelFromJson(response.body);
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
      });
    }
  }

  void _editPresente(AsistenciaAlumnoModel asistencia) async {
    final newPresente = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Presente"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Alumno ID: ${asistencia.alumnoId}"),
              Text("Fecha: ${asistencia.fecha?.toIso8601String() ?? 'N/A'}"),
              Text("Presente: ${asistencia.presente}"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(1);
                    },
                    child: Text("Presente"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(0);
                    },
                    child: Text("Ausente"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (newPresente != null) {
      setState(() {
        asistencia.presente = newPresente;
      });

      // Actualizar en el servidor
      final response = await http.put(
        Uri.parse('https://proyecto-agiles.onrender.com/asistencias/${asistencia.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(asistencia.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update asistencia');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AsistenciaAlumnoModel>? filteredAsistencias = asistencias;

    if (selectedDate != null) {
      filteredAsistencias = filteredAsistencias?.where((asistencia) {
        return asistencia.fecha?.toLocal().toIso8601String().split('T')[0] ==
            selectedDate?.toLocal().toIso8601String().split('T')[0];
      }).toList();
    }

    if (selectedMateriaId != null && selectedMateriaId!.isNotEmpty) {
      filteredAsistencias = filteredAsistencias?.where((asistencia) {
        return asistencia.materiaId == selectedMateriaId;
      }).toList();
    }

    // Obtén una lista única de materiaId para el filtro
    List<String> materiaIds = asistencias?.map((e) => e.materiaId ?? '').toSet().toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Asistencias'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Seleccionar Fecha",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                ),
                DropdownButton<String>(
                  hint: Text("Seleccionar Materia"),
                  value: selectedMateriaId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMateriaId = newValue;
                    });
                  },
                  items: materiaIds.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredAsistencias?.length ?? 0,
                    itemBuilder: (context, index) {
                      final asistencia = filteredAsistencias![index];
                      return ListTile(
                        title: Text('Alumno ID: ${asistencia.alumnoId}'),
                        subtitle: Text(
                            'Fecha: ${asistencia.fecha?.toIso8601String() ?? 'N/A'}\nPresente: ${asistencia.presente}'),
                        onTap: () => _editPresente(asistencia),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}