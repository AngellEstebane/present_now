import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/admin/inicio_administrador.dart';
import 'package:present_now/admin/maestros_departamento_screen.dart';

class Departamento {
  final int id;
  final String nombreDpt;

  Departamento({
    required this.id,
    required this.nombreDpt,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'],
      nombreDpt: json['NombreDepartamento'],
    );
  }
}

class DepartamentosScreen extends StatefulWidget {
  const DepartamentosScreen({
    super.key,
  });

  @override
  _DepartamentosScreenState createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends State<DepartamentosScreen> {
  List<Departamento> _departamentos = []; // Define the _subjects variable here

  @override
  void initState() {
    super.initState();
    _fetchDepartamentos();
  }

  Future<void> _fetchDepartamentos() async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/departamentos'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Departamento> departamentos = (jsonBody as List)
          .map((subjectJson) => Departamento.fromJson(subjectJson))
          .toList();
      setState(() {
        _departamentos = departamentos; // Assign the fetched data to _subjects
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los departamentos')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InicioAdministrador()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _departamentos.length,
        itemBuilder: (context, index) {
          final departamento = _departamentos[index];
          return ListTile(
            title: Text(departamento.nombreDpt),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MaestrosDepartamentosScreen(
                          idDept: departamento.id,
                        )),
              );
            },
          );
        },
      ),
    );
  }
}
