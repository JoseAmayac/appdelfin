import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/pages/no_connected_page.dart';
import 'package:mensajeriadelfin/src/pages/registro_page.dart';
import 'package:mensajeriadelfin/src/providers/check_connection_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:mensajeriadelfin/src/utils/alert.dart' as alert;
import 'package:mensajeriadelfin/src/utils/validators.dart' as validators;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Objeto de la clase UserProvider que interactua con la db
  final UserProvider _userProvider = new UserProvider(); 

  // Para saber si el formulario está siendo enviando
  bool _guardando = false;

  //Controladores del formulario
  final formKey = GlobalKey<FormState>();
  TextEditingController  emailInput = new TextEditingController();
  TextEditingController  passwordInput = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ConnectivityChangeNotifier connectionProvider = Provider.of<ConnectivityChangeNotifier>(context);

    if (connectionProvider.connected) {
      return Scaffold(
        body: Stack(
          children: [
            _crearFondo(context),
            _loginForm(context),
          ],
        ),
      );
    }else{
      return NoConnectionPage();
    }
  }

  Widget _crearFondo(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final fondoMorado =  Container(
      height:size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(63, 63, 156, 1.0),
            Color.fromRGBO(90, 70, 178, 1.0),
          ]
        ),
      ),
    );

    final circulo = Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Color.fromRGBO(0, 0, 0, 0.05)
      )
    );
    
    return Stack(
      children: [
        fondoMorado,
        Positioned(top: 90.0,left: 30.0,child: circulo),
        Positioned(top: -40.0,right: -30.0,child: circulo),
        Positioned(top: 250.0,right: -10.0,child: circulo),
        Positioned(bottom: -50.0,left: -20.0,child: circulo),

        Container(
          padding: EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              Icon(Icons.chat_bubble, color: Colors.white, size: 100.0),
              SizedBox(height: 10.0, width:double.infinity),
              Text('Mensajería App', style: TextStyle(color: Colors.white, fontSize: 25.0))
            ],
          ),
        )
      ],
    );
  }

  Widget _loginForm(BuildContext context){
    final size = MediaQuery.of(context).size;
    final animation = PageRouteBuilder(
      pageBuilder: (context, animation, secondAnimation){
        return RegistroPage();
      },
      transitionDuration: Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondAnimation, child){
        return SlideTransition(
            position: Tween(
                    begin: Offset(1.0, 0.0),
                    end: Offset(0.0, 0.0))
                .animate(animation),
            child: child,
        );
      }
    );
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            SafeArea(
              child: Container(
                height:180.0 
              )
            ),
      
            Container(
              width:size.width * 0.85,
              margin: EdgeInsets.symmetric(vertical: 30.0),
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Color(0xff1F1B24),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff121212),
                    blurRadius: 3.0,
                    offset: Offset(0.0, 1.0),
                    spreadRadius: 2.0
                  )
                ]
              ),
              child: Column(
                children: [
                  Text('Iniciar sesión', style: TextStyle(fontSize: 20.0, color: Colors.white70)),
                  SizedBox(height: 30.0),
                  _crearEmail(),
                  SizedBox(height: 30.0),
                  _crearPassword(),
                  SizedBox(height: 30.0),
                  _crearBoton(context)
                ],
              ),
            ),
      
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, animation),
              child: Text('Crear nueva cuenta'),
            ),
            SizedBox(height:100.0)
          ]
        ),
      ),
    );
  }

  _crearEmail(){
    return TextFormField(
      // initialValue: producto.valor.toString(),
      controller: emailInput,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        suffixIcon: Icon(Icons.email_outlined),
        // border: OutlineInputBorder(),
      ),
      // Se setea el valor cuando ya fue validado
      onSaved: (String? valor) => emailInput.text = valor!,
      validator: (String? valor) => _validateEmail(valor)
    );
  }

   _crearPassword(){
    return TextFormField(
      // initialValue: producto.valor.toString(),
      controller: passwordInput,
      obscureText: true,
      // keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: Icon(Icons.lock_outline),
        // border: OutlineInputBorder(),
      ),
      // Se setea el valor cuando ya fue validado
      onSaved: (String? valor) => passwordInput.text = valor!,
      validator: (String? valor) => _validatePassword(valor)
    );
  }

  String? _validatePassword(String? value){
    if (value == "") {
      return 'Por favor, ingrese la contraseña';
    }else{
      return null;
    }
  }

  String? _validateEmail(String? value){
    if (value == "") {
      return 'Por favor, ingrese el correo electrónico';
    }else{
      if (validators.isEmail(value!)) {
        return null;
      }else{
        return 'Formato de correo incorrecto';
      }
    }
  }

  Widget _crearBoton(BuildContext context) {
    return ElevatedButton(
      onPressed: _guardando ? null : ()=> _login(context), 
      child: Container(
        padding: EdgeInsets.symmetric(horizontal:80.0, vertical:15.0),
        child: (!_guardando)
              ? Text('Ingresar', style: TextStyle(color: Colors.white))
              : Text('Enviando...', style: TextStyle(color: Colors.white)),
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0)
          )
        ),
        elevation: MaterialStateProperty.all<double?>(0.0),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
      ),
          
    );
  }

  _login(BuildContext context) async{
    
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    setState(() {
      _guardando = true;
    });
    
    Map<String, dynamic> info = await _userProvider.login(emailInput.text, passwordInput.text);

    setState(() {
      _guardando = false;
    });

    if(info['ok']){
      Navigator.pushReplacementNamed(context, 'home');
    }else{
      alert.mostrarAlerta(context, info['message']);
    }
  }
}