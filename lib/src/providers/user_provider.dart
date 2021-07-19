import 'package:flutter/widgets.dart';
import 'package:mensajeriadelfin/src/models/user_model.dart';
import 'package:mensajeriadelfin/src/services/auth_service.dart';
import 'package:mensajeriadelfin/src/services/user_service.dart';

class UserProvider with ChangeNotifier{
  late UserService _userService;
  late AuthService _authService;

  List<User> users = [];
  UserProvider(){
    this._userService = new UserService();
    this._authService = new AuthService();
  }

  Future login(String email, String password) async {
    final response = await this._userService.login(email, password);

    if (response['ok']) {
      final user = response['user'];
      this.signIn(user);
    }

    return response;
  }

  Future register(String name, String email, String password) async {
    final response = await this._userService.register(name, email, password);

    if (response['ok']) {
      final User user = response['user'];
      this.signIn(user);
    }

    return response;
  }

  void signIn(User user){
    this._authService.signIn(user);
  }

  Future<void> getUsers() async{
    final users = await this._userService.getUsers();
    this.users = [...users];
    notifyListeners();
  }

  Future<User?> getUser(int id) async{
    return await this._userService.getUser(id);
  }

  Future getUserByEmail(String email) async{
    return await this._userService.getUserByEmail(email);
  }
}