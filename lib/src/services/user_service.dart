
import 'package:mensajeriadelfin/src/models/user_model.dart';
import 'package:mensajeriadelfin/src/utils/hash.dart';

class UserService{

  Future<Map<String, dynamic>> login(String email, String password) async{
    User user = new User(name: '', email: email, password: password);
    return await user.login();
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async{

    final passwordFinal = hashPassword(password);

    User user = new User(
      name: name,
      email: email,
      password: passwordFinal
    );
    return await user.register();
  } 

  Future<List<User>> getUsers() async{
    final user = User(name: '', email: '', password:'');
    return await user.getUsers();
  }

  Future<User> getUser(int id) async{
    User user = User(name: '', email: '', password: '');
    user.id = id;
    final data = await user.getUser();
    user.name = data['name'];
    user.email = data['email'];
    user.password = data['password'];

    return user;
  }

  Future getUserByEmail(String email) async{
    final user = User(name: '', email:email, password:'');
    return await user.getByEmail();
  }
}