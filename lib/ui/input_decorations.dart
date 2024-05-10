import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration({
    required String hintText,
    required String labelText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 15, 2, 2),
        ),
      ),
     
      
      hintText: hintText,
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 7, 11, 13),
      ),
    );
  }
}
