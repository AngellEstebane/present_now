import 'package:flutter/material.dart';
import 'package:present_now/login/login_screen.dart';
import 'package:present_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() { 
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        'login': (_) => LoginScreen(),
      },
    );
  }
}
