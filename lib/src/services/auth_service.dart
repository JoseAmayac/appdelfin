import 'package:mensajeriadelfin/src/models/auth_model.dart';
import 'package:mensajeriadelfin/src/models/user_model.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';

class AuthService{

  final _prefs = PreferenciasUsuario();
  String? _user;

  String auth(String user){
    return new Auth().generateToken(user);
  }

  bool checkToken(){
    final token = this._prefs.token;
    final auth = new Auth.fromService(token);

    if (auth.checkToken()) {
      this._user = this._prefs.user;
      return true;
    }else{
      logout();
      return false;
    }
  }

  void signIn(User user){
    String token = this.auth(user.id.toString());
    this._prefs.user = user.id.toString();
    this._prefs.token = token;
  }

  void logout(){
    this._prefs.token = null;
    this._prefs.user = null;
  }

  String? user() => this._user;
}