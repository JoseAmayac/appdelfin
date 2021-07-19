import 'dart:math';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class Auth{
  String _secret = "hsdfhdihfiodsh2h2ioh2ioh3iohiohsdfio";

  String? token;

  Auth();

  Auth.fromService(String? token) {
    this.token = token;
  }


  String generateToken(String subject){
    final payload = JwtClaim(
      issuer: 'Me',
      subject: subject,
      jwtId: _randomString(32),
      maxAge: Duration(hours: 24 * 60)
    );

    final token = issueJwtHS256(payload, this._secret);

    return token;
  }

  String _randomString(int length) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final buf = StringBuffer();

    for (var x = 0; x < length; x++) {
      buf.write(chars[rnd.nextInt(chars.length)]);
    }
    return buf.toString();
  }

  bool checkToken(){
    if (this.token == null) {
      return false;
    }

    try {
      final JwtClaim decClaimSet = verifyJwtHS256Signature(this.token!, this._secret);
      decClaimSet.validate(issuer: 'Me');
      if (decClaimSet.jwtId == null || decClaimSet.subject == null) {
        return false;
      }

      return true;

    } on JwtException catch (e) {
      print(e);
      return false;
    }
  }
}