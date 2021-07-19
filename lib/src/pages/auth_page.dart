import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/services/auth_service.dart';


class AuthPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    WidgetsBinding.instance!.addPostFrameCallback((_){
      _checkAuth(context);
    });  

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _checkAuth(BuildContext context) {
    final authService = new AuthService();
    if (!authService.checkToken()) {
      final snackbar = new SnackBar(
        content: Text('Sesión finalizada')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      
      Navigator.pushReplacementNamed(context, 'login');
    }else{
      Navigator.pushReplacementNamed(context, 'home');
    }
  }
}