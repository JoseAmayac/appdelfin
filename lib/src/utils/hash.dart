import 'package:crypt/crypt.dart';

String hashPassword(String passwordPlain){
    final hashedPassword = Crypt.sha512(passwordPlain);
    return hashedPassword.toString();
  }

  bool mathPasswords(String hashed, String plain){
    final h = Crypt(hashed);
    return h.match(plain);
  }