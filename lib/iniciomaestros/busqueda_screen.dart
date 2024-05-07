import 'package:flutter/material.dart';
import 'registro.dart';
import 'consulta_asistencia.dart';
import 'consulta_inasistencias.dart';
import 'asistencia_entrada_salida.dart';

class BusquedaScreen extends StatelessWidget {
  final List<Registro> registros;
  final Function(BuildContext) mostrarDialogoDeBusqueda;

  BusquedaScreen(
      {required this.registros, required this.mostrarDialogoDeBusqueda});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'FILTRO DE BUSQUEDA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Consulta de Asistencia'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConsultaAsistencia()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Consulta de Inasistencias'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConsultaInasistencias()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event_note),
            title: Text('Asistencia Entrada y Salida'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AsistenciaEntradaSalida()),
              );
            },
          ),
        ],
      ),
    );
  }
}
