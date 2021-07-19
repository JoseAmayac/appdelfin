import 'package:mysql1/mysql1.dart';

import 'package:mensajeriadelfin/src/models/mysql_model.dart';

class Group{
  late MySqlConnection _connection;
  
  int? id;
  String name;
  int owner;
  int? participantes;

  Group({ required this.name, required this.owner }){
    this._connection = new Mysql().connection;
  }

  Future<Map<String, dynamic>> create() async {
    final exists = await this.nameExists();

    if (exists) {
      return {
        "ok": false,
        "message": "Ya tienes un chat con ese nombre"
      };
    }

    final result = await this._connection.query('''
      INSERT INTO groups(name, owner_id) VALUES(?, ?)
    ''',[this.name, this.owner]);
    this.id = result.insertId;

    return {
      "ok": true,
      "group": this
    };
  }

  Future<bool> nameExists() async {
    final results = await this._connection.query('''
     SELECT * FROM groups WHERE name = ?
    ''',[this.name]);

    return results.length > 0;
  }

  Future<List<Group>> getGroupsByUser(int idUser) async{
    List<Group> groups = [];

    final results = await this._connection.query('''
      SELECT groups.id as id, groups.name as name, groups.owner_id as owner FROM groups INNER JOIN group_user ON group_user.group_id=groups.id WHERE group_user.user_id = ?
    ''', [idUser]);

    for (var result in results) {
      final group = Group(name: result[1], owner: result[2]);
      group.id = result[0];
      groups.add(group);
    }

    return groups;
  }

  Future getNumberParticipants() async {
    final results = await this._connection.query('''
      select count(*) as participantes from groups inner join group_user on groups.id = group_user.group_id where groups.id = ? group by groups.name;
    ''',[this.id]);

    this.participantes = results.first[0];

    return this.participantes;
  }

  Future delete() async {
    final result = await this._connection.query('''
      DELETE FROM groups WHERE id = ?
    ''',[this.id]);

    print(result);

    return {
      "ok": true,
      "message": "Chat eliminado con éxito"
    };
  }
}