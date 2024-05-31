import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_now/admin/inicio_administrador.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';
import 'package:present_now/iniciomaestros/simple_pdf_api.dart';

class Maestro {
  final String? rfc;
  final String nombre;
  final int deptId;

  Maestro({
    required this.rfc,
    required this.nombre,
    required this.deptId,
  });

  factory Maestro.fromJson(Map<String, dynamic> json) {
    return Maestro(
      rfc: json['rfc'],
      nombre: json['Nombre'],
      deptId: json['DepartamentoID'],
    );
  }
}

class MaestrosDepartamentosScreen extends StatefulWidget {
  const MaestrosDepartamentosScreen({
    super.key,
    required this.idDept,
  });
  final int idDept;

  @override
  _MaestrosDepartamentosScreenState createState() =>
      _MaestrosDepartamentosScreenState();
}

class _MaestrosDepartamentosScreenState
    extends State<MaestrosDepartamentosScreen> {
  List<Maestro> _maestros = []; // Define the _maestros variable here

  @override
  void initState() {
    super.initState();
    _fetchMaestros();
  }

  Future<void> _fetchMaestros() async {
    final response = await http
        .get(Uri.parse('https://proyecto-agiles.onrender.com/profesores'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<Maestro> maestros = (jsonBody as List)
          .map((maestroJson) => Maestro.fromJson(maestroJson))
          .toList();

      // Filter maestros based on the deptId
      final filteredMaestros =
          maestros.where((maestro) => maestro.deptId == widget.idDept).toList();

      setState(() {
        _maestros = filteredMaestros; // Assign the filtered data to _maestros
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
        itemCount: _maestros.length,
        itemBuilder: (context, index) {
          final maestro = _maestros[index];
          return ListTile(
            title: Text(maestro.nombre),
            onTap: () async {
              // final simplePdfFile =
              //     await SimplePdfApi.generateSimpleTextPdfMaestros(maestro);
              // SaveAndOpenDocument.openPdf(simplePdfFile);
            },
          );
        },
      ),
    );
  }
}
