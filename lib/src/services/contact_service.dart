import 'package:mensajeriadelfin/src/models/contact_model.dart';

class ContactService {

  Future save(int user1, int user2) async {
    final contact = new Contact(user1: user1, user2: user2);
    return await contact.save();
  }

  Future<List<Map<String, dynamic>>> getContacts(int id) async{
    final contact = new Contact(user1: -1, user2: -1);
    return await contact.allById(id);
  }
}