import 'package:flutter/material.dart';

import 'inicio_alumnos.dart';
import 'inicio_maestros.dart';

import 'package:present_now/Pages/check_auth_screen.dart';
import 'package:present_now/Pages/home_screen.dart';
import 'package:present_now/Pages/login_screen.dart';
import 'package:present_now/services/auth_services.dart';
import 'package:present_now/services/notifications_services.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IQ-Switch App',
      initialRoute: 'checking',
      routes: {
        'login': (_) => LoginScreen(),
        'home': (_) => HomeScreen(),
        'checking': (_) => CheckAuthScreen(),
        'main': (_) => MainScreen()
      },
      scaffoldMessengerKey: NotificationsService.messengerKey,
      /*theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[800],
            appBarTheme:
                const AppBarTheme(elevation: 0, color: Colors.redAccent),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.redAccent, elevation: 0))*/
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 171, 194, 232),
          appBarTheme: const AppBarTheme(elevation: 0, color: Colors.redAccent),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.redAccent, elevation: 0)),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona una opción'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InicioMaestros()),
                );
              },
              child: Text('Inicio Maestros'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InicioAlumnos()),
                );
              },
              child: Text('Inicio Alumnos'),
            ),
          ],
        ),
      ),
    );
  }
}
