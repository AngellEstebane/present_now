import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/login_form_provider.dart';
import '../services/services.dart';
import '../ui/ui.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //body: AuthBackground(
        //SingleChildScrollView para pantalla desplazable por informacion larga
        body: Container(
            child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 250),
          CardContainer(
              child: Column(
            children: [
              const SizedBox(height: 10),
              Text('Login', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 30),
              ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(), child: _LoginForm())
            ],
          )),
          const SizedBox(height: 50),
          TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, 'register'),
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 246, 244, 244)
                          .withOpacity(0.1)),
                  shape: MaterialStateProperty.all(StadiumBorder())),
              child: const Text(
                'Crear una nueva cuenta',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 41, 46, 44)),
              )),
          const SizedBox(height: 50),
        ],
      ),
    )));
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              decoration: InputDecorations.authInputDecoration(
                hintText: 'Ingresa Tu Numero de control o RFC',
                labelText: 'NC o RFC',
              ),
            ),

            TextFormField(
              decoration: InputDecorations.authInputDecoration(
                  hintText: '*****',
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contraseña debe de ser de 6 caracteres';
              },
            ),
            const SizedBox(height: 10),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical()),
                disabledColor: const Color.fromARGB(255, 13, 6, 6),
                elevation: 0,
                color: const Color.fromARGB(215, 219, 221, 252),
                child: Container(
                    padding: EdgeInsets.zero,
                    child: Text(
                      loginForm.isLoading ? 'Espere' : 'Ingresar',
                      style: TextStyle(color: Colors.black),
                    )),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final authService =
                            Provider.of<AuthService>(context, listen: false);

                        if (!loginForm.isValidForm()) return;

                        loginForm.isLoading = true;

                        // TODO: validar si el login es correcto
                        final String? errorMessage =
                            await authService.login_alumnos(
                                loginForm.numeroControl, loginForm.password);

                        if (errorMessage == null) {
                          Navigator.pushReplacementNamed(context, 'home');
                        } else {
                          // TODO: mostrar error en pantalla
                          // print( errorMessage );
                          NotificationsService.showSnackbar(errorMessage);
                          loginForm.isLoading = false;
                        }
                      }),

            //para maestros

            const SizedBox(height: 10),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical()),
                disabledColor: const Color.fromARGB(255, 13, 6, 6),
                elevation: 0,
                color: const Color.fromARGB(215, 219, 221, 252),
                child: Container(
                    padding: EdgeInsets.zero,
                    child: Text(
                      loginForm.isLoading ? 'Espere' : 'Ingresar',
                      style: TextStyle(color: Colors.black),
                    )),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final authService =
                            Provider.of<AuthService>(context, listen: false);

                        if (!loginForm.isValidForm()) return;

                        loginForm.isLoading = true;

                        // TODO: validar si el login es correcto
                        final String? errorMessage = await authService
                            .login_maestros(loginForm.rfc, loginForm.password);

                        if (errorMessage == null) {
                          Navigator.pushReplacementNamed(context, 'home');
                        } else {
                          // TODO: mostrar error en pantalla
                          // print( errorMessage );
                          NotificationsService.showSnackbar(errorMessage);
                          loginForm.isLoading = false;
                        }
                      })
          ],
        ),
      ),
    );
  }
}