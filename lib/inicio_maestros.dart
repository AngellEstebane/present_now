import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:present_now/iniciomaestros/asistencia_screen.dart';
import 'package:present_now/iniciomaestros/reportes_screen.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'iniciomaestros/avisos_screen.dart';
import 'iniciomaestros/busqueda_screen.dart';
import 'iniciomaestros/charlar_screen.dart';
import 'iniciomaestros/desconectado_screen.dart';
import 'iniciomaestros/justificantes_screen.dart';
import 'iniciomaestros/materias_screen.dart'; // Importar la pantalla de MateriasScreen
import 'iniciomaestros/mis_archivos_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InicioMaestros(),
    );
  }
}

class InicioMaestros extends StatefulWidget {
  @override
  _InicioMaestrosState createState() => _InicioMaestrosState();
}

class _InicioMaestrosState extends State<InicioMaestros>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Present Now'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BusquedaScreen(
                          registros: [],
                          mostrarDialogoDeBusqueda: (BuildContext) {},
                        )),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('URL_DE_TU_FOTO'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.nombreProfesor.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authProvider.rfc.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_pin_sharp),
              title: const Text('Asistencia'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AsistenciaScreen()),
                );
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Justificantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JustificantesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Reportes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportesScreen(
                            rfc: authProvider.rfc ?? '',
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                bool? confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmación'),
                        content:
                            const Text('¿Seguro que quieres cerrar sesión?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); //Cancelar
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); //Confirmar
                            },
                            child: const Text('Cerrar sesión'),
                          )
                        ],
                      );
                    });
                if (confirmLogout == true) {
                  // Obtener instancia de AuthProvider y llamar al método logout
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    'login',
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: FadeInDown(
          duration: const Duration(milliseconds: 700),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Estamos encantados de tenerte aquí.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
