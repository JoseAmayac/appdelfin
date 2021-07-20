import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mysql1/mysql1.dart';

class GroupUser{

  late MySqlConnection _connection;

  int? id;
  int groupId;
  int userId;

  
  GroupUser({required this.groupId, required this.userId}){
    this._connection = Mysql().connection;
  }

  Future<Map<String,dynamic>> create() async{

    try {
      final result = await _connection.query('''
        INSERT INTO group_user (group_id, user_id) VALUES(?,?)
      ''',[this.groupId, this.userId]);
      this.id = result.insertId;

      return {
        "ok": true,
        "group_user": this
      };
    } catch (e) {
      return {
        "ok": false,
        "message": "Error al asociar al usuario al grupo"
      };
    }
  }

  Future<Map<String,dynamic>> findOne() async {
    final results = await this._connection.query('''
      SELECT * FROM group_user WHERE group_id = ? AND user_id = ?
    ''', [this.groupId, this.userId]);

    if (results.length > 0) {
      return {
        "ok": false,
        "message": "Este usuario ya hace parte del grupo"
      };
    }else{
      return {
        "ok": true,
        // "groupUser": results.first
      };
    }
  }

  Future delete() async {
    try {
      final result = await this._connection.query('''
        DELETE FROM group_user WHERE group_id = ? AND user_id = ?
      ''', [this.groupId, this.userId]);

      return {
        "ok": true,
        "message": "Has abandonado el chat",
        "result": result
      };
    } catch (e) {
      return {
        "ok": false,
        "message": "Error al abandonar el grupo"
      };
    }

  }
}