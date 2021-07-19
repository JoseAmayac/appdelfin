import 'package:flutter/cupertino.dart';
import 'package:mensajeriadelfin/src/models/message_model.dart';
import 'package:mensajeriadelfin/src/services/message_service.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';

class MessageProvider with ChangeNotifier{
  late MessageService _messageService;
  final _prefs = new PreferenciasUsuario();

  List<Message> messages = [];
  
  MessageProvider(){
    this._messageService = new MessageService();
  }

  createMessage(int groupId, String body) async{
    final userId = int.parse(this._prefs.user!);

    final response = await this._messageService.createMessage(userId, groupId, body);
    
    this.messages.add(response["message"]);
    notifyListeners();
    return response;
  }

  getChatMessages(int chatId) async{
    this.messages = await this._messageService.getChatMessages(chatId);
    notifyListeners();
  }

}