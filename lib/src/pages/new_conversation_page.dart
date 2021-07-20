import 'package:flutter/material.dart';
import 'package:mensajeriadelfin/src/providers/contact_provider.dart';
import 'package:provider/provider.dart';

import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_user_provider.dart';
import 'package:mensajeriadelfin/src/utils/alert.dart';

class NewConversation extends StatefulWidget {
  
  @override
  _NewConversationState createState() => _NewConversationState();
}

class _NewConversationState extends State<NewConversation> {
  final formKey = GlobalKey<FormState>();
  TextEditingController  nameController = new TextEditingController();
  List<int> _integrantes = [];
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff121212),
        centerTitle: true,
        title: Text('Nueva conversasión'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              _formNew(context)
            ],
          ),
        ),
      )
    );  
  }

  Widget _formNew(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asignale un nombre al nuevo chat ', style: TextStyle(fontSize: 17.0)),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nombre del chat',
              suffixIcon: Icon(Icons.label),
              // border: OutlineInputBorder(),
            ),
            // Se setea el valor cuando ya fue validado
            // onSaved: (String? valor) => passwordInput.text = valor!,
            validator: (String? valor) => _validatePassword(valor)
          ),
          SizedBox(height: 30.0),
          Text('Selecciona la lista de integrantes', style: TextStyle(fontSize: 17.0)),
          SizedBox(height: 10.0),
          _listUsers(context),
          SizedBox(height: 10.0),
          _crearBotones()
        ],
      )
    );
  } 

  String? _validatePassword(String? value){

    if (value == "") {
      return "Por favor, escribe el nombre del nuevo chat";
    }else{
      return null;
    }

  }

  _listUsers(BuildContext context){
    final contactProvider = Provider.of<ContactProvider>(context);
    // final users = userProvider.users;
    double height = MediaQuery. of(context).size.height;
    return FutureBuilder(
      future: contactProvider.getContacts(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot){
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }else{
          final users = snapshot.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Color(0xff121212),
              height: height * 0.4,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(users[index].name),
                  subtitle: Text(users[index].email),
                  trailing: IconButton(
                    onPressed: (){
                      if (_integrantes.contains(users[index].id)) {
                        _integrantes.remove(users[index].id);
                      }else{
                        _integrantes.add(users[index].id!);
                      }
                      setState(() {});
                    },
                    icon: Icon(_integrantes.contains(users[index].id) ? Icons.close : Icons.check)
                  ),
                  
                ),
              )
            ),
          );
        }
      },
    );
  }

  Widget _crearBotones(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent)
          ),
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text('Cancelar',style: TextStyle(color: Colors.white60))
        ),
        SizedBox(width: 20.0,),
        ElevatedButton(
          onPressed: _guardando ? null : () => _createNewChat(context), 
          child: Text(_guardando ? 'Creando grupo' : 'Crear chat', style: TextStyle(color: Colors.white60))
        )
      ],
    );
  }

  _createNewChat(BuildContext context) async{
    if (!formKey.currentState!.validate()) return;

    if (this._integrantes.length == 0) {
      mostrarAlerta(context, 'Debes seleccionar al menos una persona de la lista');
      return;
    }

    setState(() {
      _guardando = true;
    });
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final response = await groupProvider.createGroup(this.nameController.text);

    if (!response["ok"]) {
      mostrarAlerta(context, response["message"]);
    }else{
      final groupId = response["group"].id;
      await this._addUsersToGroup(groupId);
      setState(() {
      _guardando = false;
      });
      final snackBar = SnackBar(
        content: Text('Conversación creada con éxito', 
          style: TextStyle(fontSize: 17.0)
        ),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacementNamed(context, 'home');
    }
  }

  _addUsersToGroup(int groupId) async {
    final groupUserProvider = new GroupUserProvider();
    await groupUserProvider.createGroupUser(groupId, this._integrantes);
  }
}