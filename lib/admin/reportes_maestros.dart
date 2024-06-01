import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/admin/inicio_administrador.dart';
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';
import 'package:present_now/iniciomaestros/simple_pdf_api.dart';

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
  List<AsistenciaMaestro> _asistencias = [];
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

  Future<void> _fetchAsistenciaMaestros(Profesor profesor) async {
    final response = await http.get(
        Uri.parse('https://proyecto-agiles.onrender.com/entrada/profesor'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      // Filtrar las asistencias por el RFC del profesor
      final List<AsistenciaMaestro> asistencias = (jsonBody as List)
          .where((maestroJson) => maestroJson['RFC'] == profesor.rfc)
          .map((maestroJson) => AsistenciaMaestro.fromJson(maestroJson))
          .toList();

      setState(() {
        _asistencias = asistencias;
      });

      // Generate PDF with the fetched data
      final simplePdfFile = await SimplePdfApi.generateSimpleTextMaestrosPdf(
          profesor, asistencias);
      SaveAndOpenDocument.openPdf(simplePdfFile);
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
        title: Text('Reportes de Maestros'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: _selectedDeptId,
              hint: Text('Selecciona un departamento'),
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: -1,
                  child: Text('Todos los Departamentos'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Sistemas'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Electromecánica'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('Industrial'),
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
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMaestros.length,
              itemBuilder: (context, index) {
                final maestro = _filteredMaestros[index];
                return ListTile(
                  title: Text(maestro.profesorNombre),
                  subtitle: Text('RFC: ${maestro.rfc}'),
                  onTap: () async {
                    // Handle on click here
                    await _fetchAsistenciaMaestros(maestro);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
