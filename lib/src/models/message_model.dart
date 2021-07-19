import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mysql1/mysql1.dart';

class Message {
  late MySqlConnection _connection;

  int? id;
  String body;
  int userId;
  int groupId;
  DateTime? createdAt;

  Message({required this.body, required this.userId, required this.groupId}){
    this._connection = Mysql().connection;
  }

  factory Message.fromMap(Map<String, dynamic> messageMap) => Message(
    body: messageMap["body"], 
    userId: messageMap["userId"],
    groupId: messageMap["groupId"]
  );

  Future<Map<String,dynamic>> save() async {
    try {
      final result = await this._connection.query('''

        INSERT INTO messages(body, user_id, group_id) VALUES(?, ?, ?)

      ''',[this.body, this.userId, this.groupId]);

      final id= result.insertId;

      final results = await this._connection.query('''
        SELECT created_at FROM messages WHERE id = ?
      ''', [id]);

      this.id = id;
      this.createdAt = results.first[0];

      return {
        "ok": true,
        "message": this
      };  
    } catch (e) {
      return {
        "ok": false,
        "message": "Error enviando el mensaje"
      };
    }
    
  }

  Future<List<Map<String,dynamic>>> all() async {
    List<Map<String,dynamic>> messagesMap = [];

    try {
      final results = await this._connection.query('''
        SELECT * FROM messages WHERE group_id = ? ORDER BY created_at
      ''', [this.groupId]);

      for (var message in results) {
        messagesMap.add({
          "id": message[0],
          "userId": message[1],
          "groupId": message[2],
          "body": message[3].toString(),
          "createdAt": message[4]
        });
      }

      return messagesMap;  
    } catch (e) {
      return [];
    }
    
  }

}