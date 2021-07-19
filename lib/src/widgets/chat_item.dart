import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/models/group_model.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ChatItem extends StatelessWidget {

  final Group group;

  const ChatItem({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: EdgeInsets.only(bottom: 3),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical:5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Color.fromRGBO(18, 18, 18, 0.4),
        ),
        key: UniqueKey(),
        child: ListTile(
          title: Text(group.name),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.people),
              // CircleAvatar()
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.0, color: Colors.white12),
          subtitle: Container(
            padding: EdgeInsets.only(top: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getOwnerInfo(context),
                _getMembers(context),
              ],
            ),
          ),
          onTap: () => Navigator.pushNamed(context, 'messageschat', arguments: this.group),
        )
    );
  }

  Widget _getOwnerInfo(context){
    final userProvider = UserProvider();
    return FutureBuilder(
      future: userProvider.getUser(this.group.owner),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.hasData) {
          final info = snapshot.data;
          return Text('Creado por: ${info.name}');
        }else{
          return CircularProgressIndicator();
        }
      }
    );
  }

  _getMembers(BuildContext context){
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    return FutureBuilder(
      future: groupProvider.members(this.group),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.hasData) {
          return Container(
            child: Text('${snapshot.data} personas', style: TextStyle(
              color: Color(0xffBB86FC)
            ))
          );
        }else{
          return CircularProgressIndicator();
        }
      }
    );
  }
}