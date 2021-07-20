import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mensajeriadelfin/src/models/mysql_model.dart';
import 'package:mensajeriadelfin/src/pages/auth_page.dart';
import 'package:mensajeriadelfin/src/pages/chat_page.dart';
import 'package:mensajeriadelfin/src/pages/home_page.dart';
import 'package:mensajeriadelfin/src/pages/login_page.dart';
import 'package:mensajeriadelfin/src/pages/new_conversation_page.dart';
import 'package:mensajeriadelfin/src/pages/no_connected_page.dart';
import 'package:mensajeriadelfin/src/pages/registro_page.dart';
import 'package:mensajeriadelfin/src/providers/check_connection_provider.dart';
import 'package:mensajeriadelfin/src/providers/contact_provider.dart';
import 'package:mensajeriadelfin/src/providers/group_provider.dart';
import 'package:mensajeriadelfin/src/providers/message_provider.dart';
import 'package:mensajeriadelfin/src/providers/user_provider.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';
import 'package:mensajeriadelfin/src/utils/theme.dart';
import 'package:provider/provider.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();


  final mysql = new Mysql();
  final connected = await mysql.connect();

  if (connected) {
    runApp(MyApp());
  }else{
    runApp(MyAppNoConnection());
  }
} 
  
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Color(0xff121212)));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider() ),
        ChangeNotifierProvider(create: (_) => GroupProvider() ),
        ChangeNotifierProvider(create: (_) => ContactProvider() ),
        ChangeNotifierProvider(create: (_) => MessageProvider() ),
        ChangeNotifierProvider(create: (_){
          ConnectivityChangeNotifier changeNotifier = ConnectivityChangeNotifier();
          changeNotifier.initialLoad();

          return changeNotifier;
        })
      ],
      child: MaterialApp(
        title: 'Mis mensajes',
        debugShowCheckedModeBanner: false,
        theme: temaP,
        initialRoute: '',
        
        routes: {
          '' : ( _ ) => AuthPage(),
          'login': ( _ ) => LoginPage(),
          'register': ( _ ) => RegistroPage(),
          'home' : ( _ ) => HomePage(),
          'new-chat': ( _ ) => NewConversation(),
          'messageschat': ( _ ) => ChatPage(),
          'no-connected' : ( _ ) => NoConnectionPage()
        }
      ),
    );
  }
}

class MyAppNoConnection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NoConnectionPage(),
      title: 'Mis mensajes',
      debugShowCheckedModeBanner: false,
      theme: temaP,
    );
  }
}