
import 'package:flutter/widgets.dart';
import 'package:mensajeriadelfin/src/models/user_model.dart';
import 'package:mensajeriadelfin/src/services/contact_service.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';

class ContactProvider with ChangeNotifier{

  late ContactService _contactService;
  final _prefs = new PreferenciasUsuario();


  ContactProvider()
  {
    this._contactService = new ContactService();
  }


  Future save(int user,) async {
    final idUser = int.parse(this._prefs.user!);
    return await this._contactService.save(user, idUser);
  }

  Future<List<User>> getContacts() async{
    List<User> contacts = [];
    final usersMap = await this._contactService.getContacts(int.parse(this._prefs.user!));

    for (var user in usersMap) {
      user['password'] = '';
      final userObj = User.fromMap(user);
      userObj.id = user["id"];
      
      contacts.add(userObj);
    }

    return contacts;
  }

}