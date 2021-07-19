
import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mysql1/mysql1.dart';

class Contact{
  late MySqlConnection _connection;

  int user1;
  int user2;

  Contact({required this.user1, required this.user2}){
    this._connection = Mysql().connection;
  }

  Future<Map<String, dynamic>> save() async{
    try {
      final result = await this._connection.query('''
        INSERT INTO contacts (user1_id, user2_id) VALUES(?, ?) ON DUPLICATE KEY UPDATE user1_id = ?, user2_id = ?
      ''',[this.user1, this.user2, this.user1, this.user2]);

      return {
        "ok": true,
        "result": result.insertId,
      };
    } catch (e) {
      return {
        "ok": false,
        "message": "Error consultando los contactos"
      };
    }
  }

  Future<List<Map<String, dynamic>>> allById(int id) async{
    List<Map<String, dynamic>> contacts = [];

    try {
      final results = await this._connection.query('''
        SELECT id, name, email FROM users, contacts WHERE (users.id = contacts.user1_id OR users.id = contacts.user2_id) AND (contacts.user1_id = ? OR contacts.user2_id = ?) AND users.id <> ?;
      ''', [id, id, id]);

      for (var result in results) {
        final userMap = {
          "id": result[0],
          "name": result[1],
          "email": result[2]
        };
        contacts.add(userMap);
      }

      return contacts;
    } catch (e) {
      return [];
    }
  }


}