import 'package:mensajeriadelfin/src/models/message_model.dart';

class MessageService {

  Future createMessage(int userId, int groupId, String body) async{
    final message = new Message(body: body, userId: userId, groupId: groupId);
    final response = await  message.save();

    return {
      "ok": response["ok"],
      "message": response["message"]
    };
  }

  Future<List<Message>> getChatMessages(int groupId) async{
    List<Message> messages = [];

    final message = new Message(body: '', groupId: groupId, userId: -1);
    final List<Map<String, dynamic>> messagesMap = await message.all();

    for (var messageMap in messagesMap) {
      Message newMessage = Message.fromMap(messageMap);
      newMessage.id = messageMap["id"];
      newMessage.createdAt = messageMap["createdAt"];
      messages.add(newMessage);
    }

    return messages;
  }
}