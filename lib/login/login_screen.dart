import 'package:flutter/material.dart';
import 'package:present_now/inicioalumnos/desconectado_screen.dart';
import 'package:present_now/inicioalumnos/materias_screen.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_idController.text.contains('A')) {
        await authProvider.autenticarAlumno(
          _idController.text,
          _passwordController.text,
        );
      } else {
        await authProvider.autenticarMaestro(
          _idController.text,
          _passwordController.text,
        );
      }

      // Redirigir según el rol
      if (authProvider.role == 'alumno') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesconectadoScreen()),
        );
      } else if (authProvider.role == 'maestro') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MateriasScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de inicio de sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration:
                  InputDecoration(labelText: 'ID (NumeroControl o RFC)'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
