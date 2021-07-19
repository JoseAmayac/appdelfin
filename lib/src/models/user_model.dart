import 'package:mysql1/mysql1.dart';

import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mensajeriadelfin/src/utils/hash.dart';

class User {
  late MySqlConnection _connection;

  int? id;
  String name;
  String email;
  String password;

  User({ required this.name, required this.email, required this.password  }){
    this._connection = Mysql().connection;
  }

  factory User.fromMap(Map<String, dynamic> data) => User(
    name: data['name'],
    email: data['email'],
    password: data['password']
  );

  Future<Map<String, dynamic>> login() async{
    try {
      final results = await _connection.query('''
        select * from users where email = ? 
      ''', [this.email.trim()]);

      if (results.length == 0) {
        return {
          "ok": false,
          "message": "Correo electrónico o contraseña incorrectos"
        };
      }
      Map<String, dynamic> data = {
        "name": results.first[1],
        "email": results.first[2],
        "password": results.first[3]
      };
      final User user = User.fromMap(data);
      user.id = results.first[0];

      if (!mathPasswords(user.password, this.password)) {
        return {
          "ok": false,
          "message": "Correo electrónico o contraseña incorrectos"
        };
      }

      return {
        "ok": true,
        "user": user
      };
    } catch (e) {
      print(e);
      return {
        "ok": false,
        "message": "Error al iniciar sesión"
      };
    }
    
  }

  Future<Map<String, dynamic>> register() async {
    final exists = await this.verifyEmailExists();

    if (exists) {
      return {
        "ok": false,
        "message": "El correo electrónico se encuentra en uso"
      };
    }

    try {
      final result = await this._connection.query('''
        INSERT INTO users(name, email, password) VALUES (?, ?,?)
      ''',[this.name, this.email, this.password]);

      this.id = result.insertId;

      return {
        "ok": true,
        "user": this
      };  
    } catch (e) {
      return {
        "ok": false,
        "message": "Error al registrarse"
      };
    }
    
  }

  Future<bool> verifyEmailExists() async {
    try {
      final results = await _connection.query('''
        select * from users where email = ? 
      ''', [this.email.trim()]);

      if (results.length > 0) {
        return true;
      }

      return false;  
    } catch (e) {
      return false;
    }
    
  }

  Future<List<User>> getUsers() async{
    List<User> users = [];

    try {
      final results = await _connection.query('''
        SELECT * FROM users
      ''');

      for (var fila in results) {
        final user = User(name: fila[1], email: fila[2], password: fila[3]);
        user.id = fila[0];
        users.add(user);
      }

      return users;
    } catch (e) {
      return [];
    }
  }

  Future getUser() async{
    try {
      final results = await _connection.query('''
        SELECT * FROM users WHERE id = ?
      ''', [this.id]);

      Map<String, dynamic> data = {
        "id": results.first[0],
        "name": results.first[1],
        "email": results.first[2],
        "password": results.first[3]
      };

      return {
        "ok": true,
        ...data
      };  
    } catch (e) {
      return {
        "ok": false,
        "message": "Error consultando el usuario"
      };
    }
    
  }

  Future<Map<String, dynamic>> getByEmail() async {
    try {
      final result = await this._connection.query('''
        SELECT * FROM users WHERE email = ?
      ''',[this.email]);

      if (result.length > 0) {
        final user = result.first;
        this.id = user[0];
        this.name = user[1];
        this.password = user[3];

        return {
          "ok": true,
          "user": this,
        };
      }else{
        return {
          "ok": false,
          "message": "No existe un usuario con ese email",
          "code": "404"
        };
      }  
    } catch (e) {
      return {
        "ok": false,
        "message": "Error consultando el usuario",
        "code" :"500"
      };
    }
    
  }

}