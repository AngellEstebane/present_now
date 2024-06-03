import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:present_now/iniciomaestros/models/asistencia_alumno_model.dart'; // Asegúrate de tener la ruta correcta

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
  TextEditingController numeroControlController = TextEditingController();
  bool presente = true;

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

  Future<void> registrarAsistencia() async {
    if (numeroControlController.text.isEmpty || selectedMateriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un número de control y una clave de materia')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://proyecto-agiles.onrender.com/asistencias'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "numeroControl": numeroControlController.text,
        "id_materia": selectedMateriaId,
        "presente": presente ? 1 : 0,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asistencia registrada correctamente')),
      );
      fetchAsistencias(); // Actualiza la lista de asistencias
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar la asistencia')),
      );
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
        title: const Text('Lista de Asistencias'),
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
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                ),
                DropdownButton<String>(
                  hint: const Text("Seleccionar Materia"),
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
                TextField(
                  controller: numeroControlController,
                  decoration: const InputDecoration(labelText: 'Número de Control'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Presente"),
                    Switch(
                      value: presente,
                      onChanged: (bool value) {
                        setState(() {
                          presente = value;
                        });
                      },
                    ),
                    const Text("Ausente"),
                  ],
                ),
                ElevatedButton(
                  onPressed: registrarAsistencia,
                  child: const Text('Registrar Asistencia'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredAsistencias?.length ?? 0,
                    itemBuilder: (context, index) {
                      final asistencia = filteredAsistencias![index];
                      return ListTile(
                        title: Text('Alumno ID: ${asistencia.alumnoId}'),
                        subtitle: Text(
                            'Fecha: ${asistencia.fecha?.toIso8601String() ?? 'N/A'}\nPresente: ${asistencia.presente == 1 ? 'Sí' : 'No'}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
