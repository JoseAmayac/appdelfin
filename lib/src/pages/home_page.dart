import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/pages/no_connected_page.dart';
import 'package:mensajeriadelfin/src/providers/check_connection_provider.dart';
import 'package:mensajeriadelfin/src/providers/contact_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:mensajeriadelfin/src/services/auth_service.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';
import 'package:mensajeriadelfin/src/utils/snackbar.dart';
import 'package:mensajeriadelfin/src/utils/validators.dart';
import 'package:mensajeriadelfin/src/widgets/chat_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = new AuthService();
  TextEditingController inputController = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _sending = false;
  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectivityChangeNotifier>(context);
    
    if (connectionProvider.connected) {
      return Scaffold(
        appBar: _customAppBar(context),
        body: _myBody(context),
        key: UniqueKey(),
      );
    }else{
      return NoConnectionPage();
    }
  }

  PreferredSizeWidget _customAppBar(context){
    return AppBar(
      toolbarHeight: 65,
      // elevation: 48,
      backgroundColor: Color(0xff121212),
      title: Text('Conversaciones', style: TextStyle(fontSize: 25, color: Color(0xffBB86FC))),
      actions: [
        Container(
          // padding: EdgeInsets.symmetric(vertical: 10),
          child: PopupMenuButton(
            // color: Colors.black,
            icon: Icon(Icons.more_vert, color: Color(0xffBB86FC)),
            onSelected: (result) { 
              switch (result) {
                case '1':
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  userProvider.getUsers();
                  Navigator.pushNamed(context, 'new-chat');
                  return;
                case '2':
                  _showAlertForm(context);
                  return;
                case '-1':
                  _logout(context);
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: '1',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 7),
                    Text('Nuevo chat')
                  ],
                )
              ),
              PopupMenuItem(
                value: '2',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 7),
                    Text('Nuevo contacto')
                  ],
                )
              ),
              PopupMenuItem(
                value: '-1',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xffCF6679),),
                    SizedBox(width: 7),
                    Text('Cerrar sesión', style: TextStyle(color: Color(0xffCF6679)))
                  ],
                )
              ),
            ],
          )
        )
      ],
    );
  }

  Widget _myBody(context){
    final provider = Provider.of<GroupProvider>(context, listen: false);
    provider.getGroups();

    return ChatList();
  }

  _logout(BuildContext context){
    this._authService.logout();
    Navigator.pushReplacementNamed(context, 'login');
  }

  _showAlertForm(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromRGBO(255, 255, 255, 0.05),
      builder: (BuildContext context ){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Agregar contacto nuevo', textAlign: TextAlign.center,),
          content: Form(
            key: formKey,
            child: Container(
              height: 100, 
              width: double.infinity,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      errorMaxLines: 3
                    ),
                    
                    validator: (String? value){
                      if (value == "") {
                        return "Por favor, ingresa el correo electrónico del nuevo contacto";
                      }else{
                        if (!isEmail(value!)) {
                          return "Por favor, ingresa una dirección de correo válida";
                        }else{
                          return null;
                        }
                      }
                    },
                  )
                ],
              ),
            )
          ),
          
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('Cancelar',style: TextStyle(color: Colors.white54))
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xffBB86FC)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // side: BorderSide(color: Colors.red)
                  )
                ),
                minimumSize: MaterialStateProperty.all(Size(100, 20))
              ),
              onPressed: this._sending ? null : () => _createContact(context),
              child: Text('Agregar', style: TextStyle(color: Colors.white70))
            )
          ],

        );
      }
    );
  }

  _createContact(BuildContext context) async {
    if (!formKey.currentState!.validate()) return null;
    formKey.currentState!.save();
    
    setState(() {
      _sending = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    final prefs = new PreferenciasUsuario();

    final response = await userProvider.getUserByEmail(this.inputController.text);
    setState(() {
      this._sending = false;
    });
    if(response["ok"]){
      final user = response["user"];
      if (user.id == int.parse(prefs.user!)) {
        showSnackBar(context, "error", "No puedes agregarte como amigo");
      }else{
        setState(() {
          _sending = true;
        });
        final resp = await contactProvider.save(user.id);

        setState(() {
          _sending = false;
        });
        if (resp["ok"]) {
          Navigator.of(context).pop();
          showSnackBar(context, "success", "Contacto agregado correctamente");
        }else{
          showSnackBar(context, "error", "No se pudo agregar el contacto");
        }
      }
    }else{
      showSnackBar(context, "error", response["message"]);
    }

  }
}