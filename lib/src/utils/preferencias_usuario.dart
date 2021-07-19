import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario{
  static final PreferenciasUsuario _instancia = new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  late SharedPreferences _prefs;

  Future<void> initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  String? get token{
    return this._prefs.getString("token") ?? null;
  }

  set token(String? value){
    print("Cambiando el valor del token en prefs con el valor: ");
    print(value);
    if (value != null) {
      this._prefs.setString('token', value);
    }else{
      this._prefs.remove("token");
    }
  }

  String? get user{
    return this._prefs.getString("user") ?? null;
  }

  set user(String? user){
    print("Cambiando el valor del usuario en prefs con el valor");
    print(user);
    if (user != null) {
      this._prefs.setString('user', user);
    }else{
      this._prefs.remove("user");
    }
  }
}