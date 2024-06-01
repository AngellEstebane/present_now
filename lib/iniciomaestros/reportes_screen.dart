import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';
import 'package:present_now/iniciomaestros/simple_pdf_api.dart';

class Subject {
  final int IdGrupo;
  final String Id_Materia;
  final String Hora;
  final String Aula;
  final String RfcDocente;
  final String NombreGrupo;

  Subject({
    required this.IdGrupo,
    required this.Id_Materia,
    required this.Hora,
    required this.Aula,
    required this.RfcDocente,
    required this.NombreGrupo,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      IdGrupo: json['IdGrupo'],
      Id_Materia: json['Id_Materia'],
      Hora: json['Hora'],
      Aula: json['Aula'],
      RfcDocente: json['RfcDocente'],
      NombreGrupo: json['NombreGrupo'],
    );
  }
}

class Asistencia {
  final int id;
  final String alumnoId;
  final String fecha;
  final int presente;
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
  List<Asistencia> _asistencias = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects(widget.rfc);
  }

  Future<void> _fetchSubjects(String rfc) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/grupo?RfcDocente=$rfc'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Subject> subjects = (jsonBody as List)
          .where((subjectJson) => subjectJson['RfcDocente'] == rfc)
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList();
      setState(() {
        _subjects = subjects;
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

  Future<void> _fetchAsist(Subject subject) async {
    final response = await http.get(Uri.parse(
        'https://proyecto-agiles.onrender.com/asistencias/materia?materiaID=${subject.Id_Materia}'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Asistencia> asistencias = (jsonBody as List)
          .map((asistJson) => Asistencia.fromJson(asistJson))
          .toList();
      setState(() {
        _asistencias = asistencias;
      });

      // Generate PDF with the fetched data
      final simplePdfFile = await SimplePdfApi.generateSimpleTextPdf(
          subject, subject.Id_Materia, _asistencias);
      SaveAndOpenDocument.openPdf(simplePdfFile);
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
            title: Text('Materia: ${subject.Id_Materia}'),
            subtitle: Text('grupo: ${subject.NombreGrupo}'),
            onTap: () async {
              await _fetchAsist(subject);
            },
          );
        },
      ),
    );
  }
}
