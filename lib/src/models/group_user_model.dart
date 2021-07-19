import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mysql1/mysql1.dart';

class GroupUser{

  late MySqlConnection _connection;

  int? id;
  int groupId;
  int userId;

  
  GroupUser({required this.groupId, required this.userId}){
    this._connection = new Mysql().connection;
  }

  Future<Map<String,dynamic>> create() async{

    final result = await _connection.query('''
      INSERT INTO group_user (group_id, user_id) VALUES(?,?)
    ''',[this.groupId, this.userId]);
    this.id = result.insertId;

    return {
      "ok": true,
      "group_user": this
    };
  }

  Future delete() async {
    final result = await this._connection.query('''
      DELETE FROM group_user WHERE group_id = ? AND user_id = ?
    ''', [this.groupId, this.userId]);

    return {
      "ok": true,
      "message": "Has abandonado el chat",
      "result": result
    };

  }
}