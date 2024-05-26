import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class PasswordVisibilityToggle extends ChangeNotifier {
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
}

class PasswordValidator {
  // Expresión regular para validar la contraseña
  static final RegExp regex = RegExp(
    r'^(?=.*[A-Z])(?=.*[!@#\$^&*~()_+\[\]{}|;:\",.<>?/])(?=.*[0-9])(?=.*[a-z]).{8,}$',
  );

  static bool isValid(String password) {
    return regex.hasMatch(password);
  }
}

class RFCValidator {
  static final RegExp regex = RegExp(r'^[A-Z]{3,4}[0-9]{6}[A-Z0-9]{3}$');

  static bool isValid(String rfc) {
    return regex.hasMatch(rfc) && rfc.length <= 13;
  }
}

class NumerControlValidator {
  static bool isValid(String id){
    return id.startsWith('C') && id.length == 9 || id.length == 8;
  }  
}