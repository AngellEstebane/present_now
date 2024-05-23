import 'package:flutter/material.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CerrarSesionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerrar sesión'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Mostrar diálogo de confirmación
            bool? confirmLogout = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirmación'),
                  content: Text('¿Seguro que quieres cerrar sesión?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Cancelar
                      },
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true); // Confirmar
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                );
              },
            );

            // Si el usuario confirmó el cierre de sesión
            if (confirmLogout == true) {
              // Obtener instancia de AuthProvider y llamar al método logout
              await Provider.of<AuthProvider>(context, listen: false).logout();
              // Navegar de vuelta a la pantalla de login o la pantalla de inicio
              Navigator.of(context).pushNamedAndRemoveUntil(
                'login',
                (Route<dynamic> route) => false,
              );
            }
          },
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
}
