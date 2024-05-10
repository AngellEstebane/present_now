import 'package:flutter/material.dart';

class NotificationsService {
  //globalkey da acceso al estado interno de un widget
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      new GlobalKey<ScaffoldMessengerState>();
//showSnackbar toma un mensaje como parámetro
  static showSnackbar(String message) {
    final snackBar = new SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
    messengerKey.currentState!.showSnackBar(snackBar);
  }
}
