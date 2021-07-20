import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/models/group_model.dart';
import 'package:mensajeriadelfin/src/models/user_model.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_user_provider.dart';
import 'package:mensajeriadelfin/src/providers/message_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';
import 'package:mensajeriadelfin/src/utils/snackbar.dart';
import 'package:mensajeriadelfin/src/utils/validators.dart';
import 'package:mensajeriadelfin/src/widgets/message_list.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Group group;
  ScrollController _controller = ScrollController();

  TextEditingController  messageController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formAddKey = GlobalKey<FormState>();
  TextEditingController inputController = new TextEditingController();

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    this.group = ModalRoute.of(context)!.settings.arguments as Group;

    return Scaffold(
      appBar: _myAppbar(context),
      body: _myBody(context),
      bottomSheet: _form(context)
    );
  }

  PreferredSizeWidget _myAppbar(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    final prefs = PreferenciasUsuario();
    final mine = group.owner ==  int.parse(prefs.user!);
    
    return AppBar(
      centerTitle: true,
      title: Text(group.name),
      actions: [
        IconButton(
          onPressed: (){
            messageProvider.getChatMessages(this.group.id!);
          },
          icon: Icon(Icons.refresh)
        ),
        (mine)
        ? Row(
          children: [
            IconButton(
              onPressed: (){
                _showAlertForm(context);
              }, 
              icon: Icon(Icons.person_add, color: Color(0xffBB86FC))
            ),
            IconButton(
              onPressed: (){
                showDialog(
                  context: context, 
                  builder: (BuildContext ctx){
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      title: Text('Por favor, confirma la acción', textAlign: TextAlign.center),
                      content: Text("¿Estás seguro que deseas eliminar el chat? esta acción no se puede deshacer", textAlign: TextAlign.center),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar')
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await groupProvider.deleteGroup(group.id!);
                            showSnackBar(context, "success", "Chat eliminado con éxito");
                            Navigator.of(context).pushReplacementNamed("home");
                          },
                          child: Text("Sí, eliminar")
                        )
                      ],
                    );
                  }
                );
              }, 
              icon: Icon(Icons.delete_forever, color: Color(0xffCF6679))
            ),
          ],
        )
        : IconButton(
          onPressed: () async {
            showDialog(
              context: context, 
              builder: (BuildContext ctx){
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  title: Text('Por favor, confirma la acción', textAlign: TextAlign.center),
                  content: Text("¿Estás seguro que deseas abandonar el chat? esta acción no se puede deshacer", textAlign: TextAlign.center),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancelar')
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final groupUserProvider = GroupUserProvider();
                        await groupUserProvider.leaveGroup(this.group.id!);
                        Navigator.of(context).pushReplacementNamed("home");
                      },
                      child: Text("Sí, abandonar")
                    )
                  ],
                );
              }
            );
          }, 
          icon: Icon(Icons.exit_to_app, color: Color(0xffCF6679)),
        )
      ],
    );
  }

  _showAlertForm(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context ){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Agregar nuevo usuario', textAlign: TextAlign.center,),
          content: Form(
            key: formAddKey,
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
                        return "Por favor, ingresa el correo electrónico del nuevo usuario";
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
              onPressed: this._sending ? null : () => _addUser(context),
              child: Text(this._sending ? 'Agregando' : 'Agregar', style: TextStyle(color: Colors.white70))
            )
          ],

        );
      }
    );
  }

  _addUser(BuildContext context) async {
    if (!formAddKey.currentState!.validate()) return null;
    formKey.currentState!.save();

    setState(() {
      _sending = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await userProvider.getUserByEmail(this.inputController.text);

    if(response["ok"]){
      final User user = response["user"];
      final groupUserProvider = GroupUserProvider();
      final res = await groupUserProvider.findOne(this.group.id!, user.id!);

      if (res["ok"]) {
        
        final saveResponse = await groupUserProvider.createOne(this.group.id!, user.id!);

        if (saveResponse["ok"]) {
          Navigator.of(context).pop();
          showSnackBar(context, "success", "Usuario agregado correctamente");
        }else{
          Navigator.of(context).pop();
          showSnackBar(context, "error", "Error agregando el nuevo usuario");
        }

      }else{
        Navigator.of(context).pop();
        showSnackBar(context, "error", "El usuario ya hace parte del grupo");
      }
    }else{
      Navigator.of(context).pop();
      showSnackBar(context, "error", "No existe un usuario con ese email");
    }

    setState(() {
      _sending = false;
      this.inputController.text = "";
    });

  }

  Widget _myBody(BuildContext context){
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    messageProvider.getChatMessages(this.group.id!);
    Timer(
      Duration(milliseconds: 500),
      () => _controller
          .jumpTo(_controller.position.maxScrollExtent + 250));
    return MessageList(
      controller: _controller,
    );
  }

  Widget _form(context){
    return Container(
      padding: EdgeInsets.only(left: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:[ 
          Flexible(
            child: Container(
              child: Form(
                key: formKey,
                child: TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Escribe tu mensaje',
                    border: InputBorder.none
                  ),
                  onTap: (){
                    Timer(
                      Duration(milliseconds: 300),
                      () => _controller
                          .jumpTo(_controller.position.maxScrollExtent + 250));
                  },
                )
              ),
            ),
          ),
          IconButton(
            onPressed: (){
              _sendMessage(context);
            }, 
            icon: Icon(Icons.send)
          )
        ]
      ),
    );
  }

  _sendMessage(BuildContext context) async{
    if (this.messageController.text.trim().isEmpty) return;

    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    await messageProvider.createMessage(this.group.id!, this.messageController.text);
    this.messageController.text = "";

    Timer(
      Duration(milliseconds: 300),
      () => _controller
          .jumpTo(_controller.position.maxScrollExtent + 250));
    
  }
}