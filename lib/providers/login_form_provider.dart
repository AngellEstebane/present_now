import 'package:flutter/material.dart';

//widgets dependen de ella para cualquier cambio
class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  String numeroControl = '';
  String password = '';
  String rfc = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    print(formKey.currentState?.validate());

    print('$numeroControl - $password - $rfc');

    return formKey.currentState?.validate() ?? false;
  }
}
