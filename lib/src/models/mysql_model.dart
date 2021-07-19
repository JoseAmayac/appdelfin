import 'package:mysql1/mysql1.dart';

class Mysql{
  static final Mysql _instance = Mysql._internal();

  final String  _host= "10.0.2.2",
                _user = "root",
                _password = "root",
                _db = "mensajeria";
  
  final int _port = 3306;

  late final MySqlConnection _connection;

  factory Mysql(){
    return _instance;
  }

  Mysql._internal();

  MySqlConnection get connection => _connection;

  Future<void> connect() async{
    final settings = new ConnectionSettings(
      host: this._host,
      user: this._user,
      password: this._password,
      db: this._db,
      port: this._port
    );

    this._connection = await MySqlConnection.connect(settings);
    await this._createTables();
  }

  Future _createTables() async{
    await this._connection.query('''
      CREATE TABLE IF NOT EXISTS users (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        name varchar(255),
        email varchar(255) UNIQUE,
        password varchar(255)
      );
    ''');

    await this._connection.query('''
      CREATE TABLE IF NOT EXISTS groups (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        name varchar(128) UNIQUE,
        owner_id int,

        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');

    await this._connection.query('''
      CREATE TABLE IF NOT EXISTS group_user (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        group_id int NOT NULL,
        user_id int NOT NULL,

        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');
    
    await this._connection.query('''
      CREATE TABLE IF NOT EXISTS contacts (
        user1_id int NOT NULL,
        user2_id int NOT NULL,

        FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,

        PRIMARY KEY (user1_id, user2_id)
      );
    ''');

    await this._connection.query('''

      CREATE TABLE IF NOT EXISTS messages(
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        user_id int NOT NULL,
        group_id int NOT NULL,
        body TEXT NOT NULL,
        created_at DATETIME DEFAULT NOW(),
        
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE
      );

    ''');
  }
}