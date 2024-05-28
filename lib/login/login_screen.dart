import 'package:flutter/material.dart';
import 'package:present_now/admin/inicio_administrador.dart';
import 'package:present_now/inicio_alumnos.dart';
import 'package:present_now/inicio_maestros.dart';
import 'package:present_now/inicioalumnos/materias_screen.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Ver pass
  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  // Ver pass

  // Saber si es alumno o maestro según RFC o número de control ingresado
  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (id.length > 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'El número de control o RFC no puede tener más de 13 caracteres')),
      );
      return;
    }

    if (id.startsWith('C') && id.length == 9 || id.length == 8) {
      // Si el ID comienza con 'C' y tiene 9 caracteres o solo son números y son 8 caracteres, asumimos que es un número de control válido
      try {
        await authProvider.autenticarAlumno(id, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioAlumnos(), // Navega a AsistenciasScreen
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de inicio de sesión: $e')),
        );
      }
    } else if (RegExp(r'^[A-Z]{3,4}[0-9]{6}[A-Z0-9]{3}$').hasMatch(id) &&
        id.length <= 13) {
      // Si el ID tiene el formato de RFC válido y tiene 13 caracteres, asumimos que es un RFC de maestro
      try {
        await authProvider.autenticarMaestro(id, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioMaestros(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de inicio de sesión: $e')),
        );
      }
    } else if (id.length == 1) {
      // Validar credencial de administrador (número de longitud 1)
      try {
        await authProvider.autenticarAdministrador(id, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InicioAdministrador(), // Navega a la pantalla de inicio de administradores
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de inicio de sesión: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Número de control, RFC o credencial inválido')),
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
              decoration: InputDecoration(
                  labelText: 'ID (Número de Control, RFC o Credencial)'),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9]')), // Sólo letras y números
                UpperCaseTextInputFormatter(),
              ],
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: _obscureText,
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

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
