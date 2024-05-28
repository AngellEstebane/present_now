import 'package:flutter/material.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AsistenciaScreen extends StatefulWidget {
  @override
  _InicioMaestrosState createState() => _InicioMaestrosState();
}

class _InicioMaestrosState extends State<AsistenciaScreen> {
  List<Map<String, String>> materias = [];

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  void _loadMaterias() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final materiasList =
          await authProvider.getMateriasProfesor(authProvider.rfc!);
      setState(() {
        materias = materiasList;
      });
    } catch (error) {
      // Manejar errores aquí
      print('Error al cargar las materias: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: ListView.builder(
        itemCount: materias.length,
        itemBuilder: (context, index) {
          final materia = materias[index];
          return ListTile(
            title: Text(materia['NombreMateria']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grupo: ${materia['NombreGrupo']}'),
                Text('Hora: ${materia['Hora']}'),
                Text('Aula: ${materia['AulaNombre']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
