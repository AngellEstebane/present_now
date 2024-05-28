import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';
import 'package:present_now/iniciomaestros/simple_pdf_api.dart';

class Maestro {
  final String rfc;
  final String profesorNombre;

  Maestro({
    required this.rfc,
    required this.profesorNombre,
  });

  factory Maestro.fromJson(Map<String, dynamic> json) {
    return Maestro(
      rfc: json['RFC'],
      profesorNombre: json['Nombre'],
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
  List<Maestro> _maestros = []; // Define the _subjects variable here

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/profesores'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Maestro> maestros = (jsonBody as List)
          .map((subjectJson) => Maestro.fromJson(subjectJson))
          .toList();
      setState(() {
        _maestros = maestros; // Assign the fetched data to _subjects
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _maestros.length,
        itemBuilder: (context, index) {
          final subject = _maestros[index];
          return ListTile(
            title: Text(subject.profesorNombre),
            onTap: () async {
              // Handle on click here
              //print('Subject ${subject.idMateria} clicked');
            },
          );
        },
      ),
    );
  }
}
