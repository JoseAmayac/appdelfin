import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/models/group_model.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/widgets/chat_item.dart';
import 'package:provider/provider.dart';


class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    List<Group> groups = provider.groups;

    return (groups.length > 0)
      ? ListView.builder(
        key: UniqueKey(),
        itemCount: groups.length,
        itemBuilder: (context, index){
          return ChatItem(group: groups[index]);
        }
      )
      : Center(
        child: Text('No hay chats para mostrar'),
      );
  }
}