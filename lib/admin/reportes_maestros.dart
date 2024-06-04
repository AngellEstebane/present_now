import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:present_now/admin/inicio_administrador.dart';
import 'package:present_now/admin/simple_pdf_api_admin.dart';
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';

class Profesor {
  final String rfc;
  final String profesorNombre;
  final int departamentoId;

  Profesor({
    required this.rfc,
    required this.profesorNombre,
    required this.departamentoId,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) {
    return Profesor(
      rfc: json['RFC'],
      profesorNombre: json['Nombre'],
      departamentoId: json['DepartamentoID'],
    );
  }
}

class AsistenciaMaestro {
  final int id;
  final String profesorRFC;
  final String fechaHora;
  final int entro;
  final String aula;

  AsistenciaMaestro({
    required this.id,
    required this.profesorRFC,
    required this.fechaHora,
    required this.entro,
    required this.aula,
  });

  factory AsistenciaMaestro.fromJson(Map<String, dynamic> json) {
    return AsistenciaMaestro(
      id: json['id'],
      profesorRFC: json['ProfesorRFC'],
      fechaHora: json['FechaHora'],
      entro: json['Entro'],
      aula: json['aula'],
    );
  }
}

class ReportesScreenMaestros extends StatefulWidget {
  const ReportesScreenMaestros({
    super.key,
  });

  @override
  _ReportesScreenMaestrosState createState() => _ReportesScreenMaestrosState();
}

class _ReportesScreenMaestrosState extends State<ReportesScreenMaestros> {
  List<Profesor> _maestros = [];
  final List<AsistenciaMaestro> _asistencias = [];
  List<Profesor> _filteredMaestros = [];
  TextEditingController _searchController = TextEditingController();
  int? _selectedDeptId;

  @override
  void initState() {
    super.initState();
    _fetchMaestros();
    _searchController.addListener(_filterMaestros);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaestros() async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/profesores'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Profesor> maestros = (jsonBody as List)
          .map((maestroJson) => Profesor.fromJson(maestroJson))
          .toList();

      setState(() {
        _maestros = maestros;
        _filteredMaestros = maestros;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las materias')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InicioMaestros()),
      );
    }
  }

  Future<void> _fetchAsistenciaMaestros(Profesor profesor, String fecha) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/entrada/profesorfecha?fecha=$fecha'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        _asistencias.clear();
      });

      // Filtrar las asistencias para obtener solo las del profesor seleccionado
      final List<AsistenciaMaestro> asistenciasDelProfesor = jsonResponse
          .where((asistencia) => asistencia['ProfesorRFC'] == profesor.rfc)
          .map((asistenciaJson) => AsistenciaMaestro.fromJson(asistenciaJson))
          .toList();

      // Agregar las asistencias filtradas a la lista _asistencias
      setState(() {
        _asistencias.addAll(asistenciasDelProfesor);
      });

      // Generar y abrir el PDF con los datos obtenidos
      if (_asistencias.isNotEmpty) {
        final simplePdfFile = await SimplePdfApiMaestros.generateSimpleTextPdf(
            profesor, _asistencias, fecha);
        SaveAndOpenDocument.openPdf(simplePdfFile);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay registro en esta fecha')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las asistencias')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InicioAdministrador()),
      );
    }
  }

  void _filterMaestros() {
    List<Profesor> filtered = _maestros;
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((maestro) {
        return maestro.profesorNombre
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
    if (_selectedDeptId != null && _selectedDeptId != -1) {
      filtered = filtered.where((maestro) {
        return maestro.departamentoId == _selectedDeptId;
      }).toList();
    }
    setState(() {
      _filteredMaestros = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 24, 81, 180),
        title: Text(
          'Reportes de Maestros',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 24, 81, 180), Color(0xFFE1F5FF)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search,
                        color: Color.fromARGB(255, 35, 34, 34)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButton<int>(
                  value: _selectedDeptId,
                  hint: Text(
                    'Selecciona un departamento',
                    style: TextStyle(color: Color.fromARGB(255, 57, 42, 222)),
                  ),
                  isExpanded: true,
                  dropdownColor: Color.fromARGB(255, 24, 81, 180),
                  iconEnabledColor: Color.fromARGB(255, 71, 22, 169),
                  style: TextStyle(color: Colors.white),
                  items: [
                    DropdownMenuItem(
                      value: -1,
                      child: Text('Todos los Departamentos',
                          style: TextStyle(
                              color: Color.fromARGB(255, 500, 224, 224))),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Sistemas',
                          style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Electromecánica',
                          style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('Industrial',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDeptId = value;
                    });
                    _filterMaestros();
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMaestros.length,
                itemBuilder: (context, index) {
                  final maestro = _filteredMaestros[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5.0,
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        maestro.profesorNombre,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'RFC: ${maestro.rfc}',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () async {
                        // Handle on click here
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                        );
                        if (selectedDate != null) {
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                          await _fetchAsistenciaMaestros(
                              maestro, formattedDate);
                        }
                      },
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
