import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/models/group_model.dart';
import 'package:mensajeriadelfin/src/pages/no_connected_page.dart';
import 'package:mensajeriadelfin/src/providers/check_connection_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_user_provider.dart';
import 'package:mensajeriadelfin/src/providers/message_provider.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';
import 'package:mensajeriadelfin/src/utils/snackbar.dart';
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
  @override
  Widget build(BuildContext context) {
    final ConnectivityChangeNotifier connectionProvider = Provider.of<ConnectivityChangeNotifier>(context);
    this.group = ModalRoute.of(context)!.settings.arguments as Group;

    if(connectionProvider.connected){
      return Scaffold(
        appBar: _myAppbar(context),
        body: _myBody(context),
        bottomSheet: _form(context)
      );
    }else{
      return NoConnectionPage();
    }
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
        ? IconButton(
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