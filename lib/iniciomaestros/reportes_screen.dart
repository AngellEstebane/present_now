import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';
import 'package:present_now/iniciomaestros/simple_pdf_api.dart';

class Subject {
  final String rfc;
  final String profesorNombre;
  final String nombreGrupo;
  final String nombreMateria;
  final String aulaNombre;
  final String hora;

  Subject({
    required this.rfc,
    required this.profesorNombre,
    required this.nombreGrupo,
    required this.nombreMateria,
    required this.aulaNombre,
    required this.hora,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      rfc: json['RFC'],
      profesorNombre: json['ProfesorNombre'],
      nombreGrupo: json['NombreGrupo'],
      nombreMateria: json['NombreMateria'],
      aulaNombre: json['AulaNombre'],
      hora: json['Hora'],
    );
  }
}

class Asistencia {
  final String id;
  final String alumnoId;
  final String fecha;
  final String presente;
  final String materiaId;
  final String fechaConHora;

  Asistencia({
    required this.id,
    required this.alumnoId,
    required this.fecha,
    required this.presente,
    required this.materiaId,
    required this.fechaConHora,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'],
      alumnoId: json['AlumnoID'],
      fecha: json['fecha'],
      presente: json['Presente'],
      materiaId: json['materiaId'],
      fechaConHora: json['fechaConHora'],
    );
  }
}

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key, required this.rfc});
  final String rfc;

  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<Subject> _subjects = [];
  List<Asistencia> _asistencias = []; // Define the _subjects variable here

  @override
  void initState() {
    super.initState();
    _fetchSubjects(widget.rfc);
  }

  Future<void> _fetchSubjects(String rfc) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/profesor/materias/aulas?rfc=$rfc'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Subject> subjects = (jsonBody as List)
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList();
      setState(() {
        _subjects = subjects; // Assign the fetched data to _subjects
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

  Future<void> _fetchAsist(String materiaID) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/asistencias/materias?materiaID$materiaID'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Asistencia> asistencias = (jsonBody as List)
          .map((asistJson) => Asistencia.fromJson(asistJson))
          .toList();
      setState(() {
        _asistencias = asistencias; // Assign the fetched data to _subjects
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las asistencias')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InicioMaestros()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          return ListTile(
            title: Text(subject.nombreMateria),
            onTap: () async {
              // Handle on click here
              //print('Subject ${subject.idMateria} clicked');
              final simplePdfFile =
                  await SimplePdfApi.generateSimpleTextPdf(subject);
              SaveAndOpenDocument.openPdf(simplePdfFile);
            },
          );
        },
      ),
    );
  }
}
