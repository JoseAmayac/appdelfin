import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/models/message_model.dart';
import 'package:mensajeriadelfin/src/providers/message_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageList extends StatelessWidget {
  final ScrollController controller;

  MessageList({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    final messages = messageProvider.messages;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 60),
      controller: controller,
      itemCount: messages.length,
      itemBuilder: (BuildContext ctx, int index){
        return _message(ctx, messages[index]);
      }
    );
  }

  Widget _message(BuildContext ctx, Message message){
    final prefs = PreferenciasUsuario();
    final mine = message.userId ==  int.parse(prefs.user!);
    final agotime = message.createdAt!.toLocal();

    final size = MediaQuery.of(ctx).size;

    return Container(
      margin: mine ?  EdgeInsets.only(left: size.width * .2, top: 5, right: 2) : EdgeInsets.only(right: size.width * .2, top: 5, left:2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xff121212),
      ),
      child: ListTile(
        title: Text(message.body, textAlign: mine ? TextAlign.right : TextAlign.left),
        subtitle: Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getUserInfo(message.userId),
              Text(timeago.format(agotime, locale: 'es'), style: TextStyle(fontSize: 10, color: Color(0xffBB86FC))),
            ]),
        ),
      ),
    );
  }

  Widget _getUserInfo(int userId){
    final userProvider = UserProvider();
    
    return FutureBuilder(
      future: userProvider.getUser(userId),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.hasData) {
          final user = snapshot.data;

          return Text(user.name, style: TextStyle(fontSize: 10, color: Color(0xffBB86FC)));
        }else{
          return Center(
            child: CircularProgressIndicator()
          );
        }

      }
    );
  }
  
}